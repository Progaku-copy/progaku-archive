# == Schema Information
#
# Table name: tags
#
#  id              :bigint           not null, primary key
#  name(タグ名)    :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  memo_id(メモID) :integer          not null
#
# Indexes
#
#  index_tags_on_memo_id  (memo_id)
#
class Tag < ApplicationRecord
  validates :name, presence: true
  belongs_to :memo
end
