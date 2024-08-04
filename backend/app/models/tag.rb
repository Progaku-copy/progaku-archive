# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Tag < ApplicationRecord
  has_many :memo_tags
  has_many :memos, through: :memo_tags

  validates :name, presence: true, uniqueness: true
end
