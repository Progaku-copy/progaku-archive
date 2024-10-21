# frozen_string_literal: true

# == Schema Information
#
# Table name: comments
#
#  id                        :bigint           not null, primary key
#  content(内容)             :string(1024)     not null
#  poster(Slackのユーザー名) :string(50)       not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  memo_id(メモID)           :bigint           not null
#
# Indexes
#
#  index_comments_on_memo_id  (memo_id)
#
# Foreign Keys
#
#  fk_comments_memo_id  (memo_id => memos.id)
#

FactoryBot.define do
  factory :comment do
    content { 'sample_comment' }
    poster { Faker::Name.name }
    memo
  end
end
