# frozen_string_literal: true

# == Schema Information
#
# Table name: comments
#
#  id                                             :bigint           not null, primary key
#  content(内容)                                  :string(1024)     not null
#  poster_user_key(Slackの投稿者のID)             :string(255)      not null
#  slack_parent_ts(Slackの親メッセージの投稿時刻) :string(255)      not null
#  created_at                                     :datetime         not null
#  updated_at                                     :datetime         not null
#  memo_id(メモID)                                :bigint           not null
#
# Indexes
#
#  index_comments_on_memo_id          (memo_id)
#  index_comments_on_poster_user_key  (poster_user_key)
#  index_comments_on_slack_parent_ts  (slack_parent_ts) UNIQUE
#
# Foreign Keys
#
#  fk_comments_memo_id          (memo_id => memos.id)
#  fk_comments_poster_user_key  (poster_user_key => posters.user_key)
#

FactoryBot.define do
  factory :comment do
    content { 'sample_comment' }
    poster { Faker::Name.name }
    memo
  end
end
