# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

# Slack APIクライアントモジュール
# Slack APIを使用して、ユーザー、チャンネルの投稿、スレッド情報を取得します。
module SlackApiClient
  # Slack APIのエンドポイントURLを定数として定義
  SLACK_USER_URL = 'https://slack.com/api/users.list' # ユーザー一覧取得用
  SLACK_CHANNEL_BASE_URL = 'https://slack.com/api/conversations.history' # チャンネル投稿取得用
  SLACK_THREAD_BASE_URL = 'https://slack.com/api/conversations.replies' # スレッド投稿取得用
  private_constant :SLACK_USER_URL, :SLACK_CHANNEL_BASE_URL, :SLACK_THREAD_BASE_URL

  # Slackのチャンネル情報とアーカイブリアクション設定をRailsの設定から取得
  SLACK_CHANNELS = Rails.application.config.slack[:channels].freeze
  private_constant :SLACK_CHANNELS
  ARCHIVE_REACTION = Rails.application.config.slack[:archive_reaction].freeze
  private_constant :ARCHIVE_REACTION

  # Slackの投稿情報を格納する構造体
  # @!attribute post_text [String] 投稿のテキスト
  # @!attribute poster_user_key [String] 投稿者のユーザーID
  # @!attribute ts [String] 投稿のタイムスタンプ
  # @!attribute tag_id [Integer] タグのID
  # @!attribute thread_ts [String, nil] スレッドの親投稿のタイムスタンプ
  # @!attribute channel_id [String] チャンネルID
  SlackPost = Struct.new(:post_text, :poster_user_key, :ts, :tag_id, :thread_ts, :channel_id, keyword_init: true)

  # Slackのスレッド情報を格納する構造体
  # @!attribute thread_text [String] スレッド投稿のテキスト
  # @!attribute poster_user_key [String] 投稿者のユーザーID
  # @!attribute parent_ts [String] スレッドの親投稿のタイムスタンプ
  SlackThread = Struct.new(:thread_text, :poster_user_key, :parent_ts, keyword_init: true)
  
  class << self
    # Slack API: ユーザー一覧を取得
    # @return [Hash] APIレスポンス
    def fetch_slack_users
      fetch_data(SLACK_USER_URL)
    end

    # Slack API: チャンネルごとの投稿データを取得
    # @return [Array<SlackPost>] アーカイブ対象の投稿データ
    def fetch_channels_data
      SLACK_CHANNELS.flat_map { |channel| fetch_archive_posts(channel) }
    end

    # Slack API: 指定チャンネルのアーカイブ対象投稿を取得
    # @param channel [Hash] チャンネル情報 (channel_id, tag_idなどを含む)
    # @return [Array<SlackPost>] アーカイブ対象の投稿データ
    def fetch_archive_posts(channel)
      response_data = fetch_data(SLACK_CHANNEL_BASE_URL, { channel: channel[:channel_id] })

      response_data['messages'].filter_map do |post|
        next unless post['reactions']&.any? { |reaction| reaction['name'].include?(ARCHIVE_REACTION) }

        SlackPost.new(
          post_text: post['text'],
          poster_user_key: post['user'],
          ts: post['ts'],
          tag_id: channel[:tag_id],
          channel_id: channel[:channel_id],
          thread_ts: post['thread_ts']
        )
      end
    end

    # Slack API: スレッド内の投稿を取得
    # @param channel_id [String] チャンネルID
    # @param thread_ts [String] スレッドの親投稿のタイムスタンプ
    # @return [Array<SlackThread>] スレッド内の投稿データ
    def fetch_archive_threads(channel_id, thread_ts)
      results = fetch_data(SLACK_THREAD_BASE_URL, { channel: channel_id, ts: thread_ts })

      results['messages'].filter_map do |thread|
        SlackThread.new(
          thread_text: thread['text'],
          poster_user_key: thread['user'],
          parent_ts: thread['thread_ts']
        )
      end
    end

    private

    # APIリクエストを送信してレスポンスを取得
    # @param base_url [String] APIのエンドポイントURL
    # @param params [Hash] クエリパラメータ
    # @return [Hash] APIレスポンス
    def fetch_data(base_url, params = {})
      uri = URI.parse(base_url)
      uri.query = URI.encode_www_form(params) unless params.empty?
      request = build_authorization_header(uri)
      execute_request(uri, request)
    end

    # Slack APIリクエスト用の認証ヘッダーを生成
    # @param uri [URI] リクエスト先のURI
    # @return [Net::HTTP::Get] リクエストオブジェクト
    def build_authorization_header(uri)
      slack_api_token = ENV.fetch('SLACK_API_TOKEN') { raise 'SLACK_API_TOKEN is not set in the environment' }
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{slack_api_token}"
      request
    end

    # HTTPリクエストを実行
    # @param uri [URI] リクエスト先のURI
    # @param request [Net::HTTP::Get] リクエストオブジェクト
    # @return [Hash] APIレスポンス
    def execute_request(uri, request)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end
      handle_response(response)
    end

    # APIレスポンスを処理
    # 成功時はJSONを返し、エラー時は例外をスロー
    # @param response [Net::HTTPResponse] HTTPレスポンス
    # @raise [RuntimeError] エラー内容
    def handle_response(response)
      if response.is_a?(Net::HTTPSuccess)
        body = JSON.parse(response.body)
        check_slack_api_error(body)
        body
      else
        handle_http_error(response)
      end
    end

    # Slack APIのエラーレスポンスをチェック
    # @param body [Hash] APIレスポンスのボディ
    # @raise [RuntimeError] エラー内容
    def check_slack_api_error(body)
      return if body['ok']

      error_message = body['error'] || 'Unknown Slack API error'
      Rails.logger.error("Slack API Error: #{error_message}")
      raise "Slack API Error: #{error_message}"
    end

    # HTTPエラーを処理
    # @param response [Net::HTTPResponse] HTTPレスポンス
    # @raise [RuntimeError] エラー内容
    def handle_http_error(response)
      error_message = "HTTP Error: #{response.message} (HTTP #{response.code})"
      Rails.logger.error(error_message)
      raise error_message
    end
  end
end
