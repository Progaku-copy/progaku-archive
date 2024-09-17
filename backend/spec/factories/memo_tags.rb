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
#  index_memo_tags_on_memo_id             (memo_id)
#  index_memo_tags_on_memo_id_and_tag_id  (memo_id,tag_id) UNIQUE
#  index_memo_tags_on_tag_id              (tag_id)
#
# Foreign Keys
#
#  fk_memo_tags_memo_id  (memo_id => memos.id)
#  fk_memo_tags_tag_id   (tag_id => tags.id)
#
FactoryBot.define do
  factory :memo_tag do
    memo { association(:memo, strategy: :build, memo_tags: [instance]) }
    tag { association(:tag, strategy: :build, memo_tags: [instance]) }
  end
end
