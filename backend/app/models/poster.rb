class Poster < ApplicationRecord
  has_many :memos
  has_many :comments
  validates :user_key, presence: true, uniqueness: true
end