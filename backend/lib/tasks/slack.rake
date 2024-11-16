# frozen_string_literal: true

require_relative '../api_client'

# SlackのAPIのURL
SLACK_USER_URL = 'https://slack.com/api/users.list'
SLACK_CHANNEL_BASE_URL = 'https://slack.com/api/conversations.history'
SLACK_THREAD_BASE_URL = 'https://slack.com/api/conversations.replies'

namespace :slack do
  desc '転職チャンネルの投稿のimport'
  task :import_channel, %i[channel_id tag_id] => :environment do |_t, args|
    channel_id = args[:channel_id]
    tag_id = args[:tag_id]

    # Slackのユーザ名の取得
    slack_users = fetch_slack_users
    # チャンネル投稿の取得
    slack_channel_response = ApiClient.fetch_data(SLACK_CHANNEL_BASE_URL, { channel: channel_id })

    # memoテーブルのIDの最大値を取得
    max_memo_id = Memo.order(id: :desc).limit(1).pick(:id)
    # メモの作成
    result = insert_slack_memos(target_data: slack_channel_response, slack_users: slack_users, max_memo_id: max_memo_id)

    # コメントの作成
    insert_slack_comments(target_data: result[:memo_with_threads], slack_users: slack_users, channel_id: channel_id)

    # タグの作成
    insert_tags(result[:memo_ids], tag_id)
  end

  desc 'JSONファイルのimport'
  task :import_json, %i[channel_id tag_id file_path] => :environment do |_t, args|
    channel_id = args[:channel_id]
    tag_id = args[:tag_id]
    file_path = args[:file_path]

    # JSONファイルの読み込み
    target_data = JSON.parse(File.read(file_path))

    # Slackのユーザ名の取得
    slack_users = fetch_slack_users

    # memoテーブルのIDの最大値を取得
    max_memo_id = Memo.order(id: :desc).limit(1).pick(:id)
    # メモの作成
    result = insert_slack_memos(target_data: target_data, slack_users: slack_users, max_memo_id: max_memo_id)

    # コメントの作成
    insert_slack_comments(target_data: result[:memo_with_threads], slack_users: slack_users, channel_id: channel_id)

    # タグの作成
    insert_tags(result[:memo_ids], tag_id)
  end
end

# @return Hash
def fetch_slack_users
  slack_user_response = ApiClient.fetch_data(SLACK_USER_URL)

  slack_user_response['members'].to_h do |user|
    display_name = user['profile']['display_name']
    real_name = user['real_name']
    [user['id'], display_name.empty? ? real_name : display_name]
  end
end

def insert_slack_memos(target_data:, slack_users:, max_memo_id:) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  memo_values = []
  memo_with_threads = {}
  memo_ids = []

  target_data['messages'].each do |message|
    next if message['text'].end_with?('さんがチャンネルに参加しました')

    max_memo_id += 1
    memo_values << Memo.new(title: message['text'][0..20],
                            content: replace_user_mentions(message['text'], slack_users),
                            poster: slack_users[message['user']])
    memo_with_threads[message['thread_ts']] = max_memo_id if message['thread_ts']
    memo_ids << max_memo_id
  end
  Memo.import memo_values

  { memo_with_threads: memo_with_threads, memo_ids: memo_ids }
end

def insert_slack_comments(target_data:, slack_users:, channel_id:)
  comment_values = [] # commentテーブルの値を格納する配列

  # メモのスレッドを取得し、コメントを作成
  target_data.each do |thread_ts, memo_id|
    slack_thread_response = ApiClient.fetch_data(SLACK_THREAD_BASE_URL, { channel: channel_id, ts: thread_ts })

    slack_thread_response['messages'].each do |message|
      comment_values << Comment.new(
        memo_id: memo_id,
        content: replace_user_mentions(message['text'], slack_users),
        poster: slack_users[message['user']]
      )
    end
  end
  Comment.import comment_values
end

def insert_tags(memo_ids, tag_id)
  tag_values = [] # tagテーブルの値を格納する配列
  memo_ids.each do |memo_id|
    tag_values << MemoTag.new(
      memo_id: memo_id,
      tag_id: tag_id
    )
  end
  MemoTag.import tag_values
end

def replace_user_mentions(text, slack_users)
  text.gsub(/<@(\w+)>/) do |_match|
    user_id = Regexp.last_match(1)
    "@#{slack_users[user_id] || 'unknown'}"
  end
end
