# frozen_string_literal: true

# == Schema Information
#
# Table name: comments
#
#  id                                             :bigint           not null, primary key
#  content(内容)                                  :text(65535)      not null
#  poster_user_key(Slackの投稿者のID)             :string(255)      not null
#  slack_parent_ts(Slackの親メッセージの投稿時刻) :string(255)      not null
#  slack_ts(Slackの投稿時刻)                      :string(255)      not null
#  created_at                                     :datetime         not null
#  updated_at                                     :datetime         not null
#  memo_id(メモID)                                :bigint           not null
#
# Indexes
#
#  index_comments_on_memo_id          (memo_id)
#  index_comments_on_poster_user_key  (poster_user_key)
#  index_comments_on_slack_parent_ts  (slack_parent_ts)
#  index_comments_on_slack_ts         (slack_ts) UNIQUE
#
# Foreign Keys
#
#  fk_comments_memo_id          (memo_id => memos.id)
#  fk_comments_poster_user_key  (poster_user_key => posters.user_key)
#
class Comment < ApplicationRecord
  validates :content, presence: true
  validates :slack_parent_ts, presence: true
  belongs_to :memo
  belongs_to :poster,
             class_name: 'Poster',
             foreign_key: 'poster_user_key',
             primary_key: 'user_key',
             inverse_of: :comments

  def slack_posted_at
    return if slack_ts.blank?

    seconds, fractional = slack_ts.split('.')
    fractional = fractional.to_s.ljust(6, '0')[0, 6]
    Time.zone.at(seconds.to_i, fractional.to_i)
  end

  # Slack APIから取得した投稿情報からアーカイブ対象のコメントのHashを生成する
  # @param channels_data [Array<SlackApiClient::SlackPost>] Slackの投稿情報
  # @return [Array<Hash>] アーカイブ対象のコメント情報
  def self.build_archive_comments(channels_data)
    channels_data.flat_map do |post|
      next unless post.thread_ts

      thread_list = SlackApiClient.fetch_archive_threads(post.channel_id, post.thread_ts)

      memo_id = Memo.find_by(slack_ts: post.ts).id

      thread_list.map do |thread|
        {
          content: thread.thread_text,
          poster_user_key: thread.poster_user_key,
          memo_id: memo_id,
          slack_parent_ts: thread.parent_ts,
          slack_ts: thread.ts
        }
      end
    end.compact
  end
end
