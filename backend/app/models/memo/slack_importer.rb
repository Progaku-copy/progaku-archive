# frozen_string_literal: true

class Memo
  class SlackImporter
    class << self
      # Slackの投稿情報からメモ(Slackの投稿)、コメント(Slackのスレッド)をインポートする
      # @return [Boolean] インポートに成功した場合はtrue、失敗した場合はfalse

      def save
        channels_data = SlackApiClient.fetch_channels_data

        ActiveRecord::Base.transaction do
          archive_memo_params = build_archive_memo(channels_data)
          Memo.import! archive_memo_params, on_duplicate_key_update: %i[title content]

          memo_tag_params = build_archive_memo_tags(channels_data)
          MemoTag.import! memo_tag_params, on_duplicate_key_update: %i[memo_id tag_id]

          comment_params = Comment.build_archive_comments(channels_data)
          Comment.import! comment_params, on_duplicate_key_update: %i[content] if comment_params.present?
          true
        end
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.debug e.message
        false
      end

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def save_for_file
        ActiveRecord::Base.transaction do
          # ディレクトリ内のファイルを取得
          dir_path = 'db/data/import_files' # ディレクトリのパスを指定
          Dir.glob("#{dir_path}/*.json") do |file_path| # JSONファイルのみを対象
            # ファイルを読み込んでJSON解析
            file_data = JSON.parse(File.read(file_path, encoding: 'bom|utf-8'), symbolize_names: true)
            channels_data = SlackApiClient.format_archive_posts(file_data)

            archive_memo_params = build_archive_memo(channels_data)
            Memo.import! archive_memo_params, on_duplicate_key_update: %i[title content]

            memo_tag_params = build_archive_memo_tags(channels_data)
            MemoTag.import! memo_tag_params, on_duplicate_key_update: %i[memo_id tag_id]

            comment_params = Comment.build_archive_comments(channels_data)
            Comment.import! comment_params, on_duplicate_key_update: %i[content] if comment_params.present?
          end
          true
        end
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.debug e.message
        false
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      # アーカイブ対象のメモのHashを生成する
      # @param channels_data [Array<SlackApiClient::SlackPost>] Slackの投稿情報
      # @return [Array<Hash>] アーカイブ対象のメモ情報
      def build_archive_memo(channels_data)
        channels_data.map do |post|
          {
            title: post.post_text[0..20],
            content: post.post_text,
            poster_user_key: post.poster_user_key,
            slack_ts: post.ts
          }
        end
      end

      # アーカイブ対象のメモとタグの関連付けのHashを生成する
      # @param channels_data [Array<SlackApiClient::SlackPost>] Slackの投稿情報
      # @return [Array<Hash>] アーカイブ対象のメモとタグの関連付け情報
      def build_archive_memo_tags(channels_data)
        ts_values = channels_data.map(&:ts)
        memo_ids = Memo.where(slack_ts: ts_values).pluck(:slack_ts, :id)

        memo_ids.map do |slack_ts, memo_id|
          {
            memo_id: memo_id,
            tag_id: find_tag_id(slack_ts, channels_data)
          }
        end
      end

      # Slackの投稿情報からタグIDを取得する
      # @param target_ts [String] Slackの投稿時刻
      # @param channels_data [Array<SlackApiClient::SlackPost>] Slackの投稿情報
      def find_tag_id(target_ts, channels_data)
        channels_data.find { |post| post.ts == target_ts }&.tag_id
      end
    end
  end
end
