# frozen_string_literal: true

# == Schema Information
#
# Table name: memo_tags
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  memo_id    :bigint           not null
#  tag_id     :bigint           not null
#
# Indexes
#
#  index_memo_tags_on_memo_id  (memo_id)
#  index_memo_tags_on_tag_id   (tag_id)
#
# Foreign Keys
#
#  fk_memo_tags_memo_id  (memo_id => memos.id)
#  fk_memo_tags_tag_id   (tag_id => tags.id)

FactoryBot.define do
  factory :memo_tag do
    memo { nil }
    tag { nil }
  end
end
