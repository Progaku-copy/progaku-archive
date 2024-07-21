# frozen_string_literal: true

# == Schema Information
#
# Table name: memos
#
#  id                    :bigint           not null, primary key
#  content(メモの本文)   :text(65535)      not null
#  title(メモのタイトル) :string(255)      not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class Memo < ApplicationRecord
  validates :title, :content, presence: true
  has_many :comments, dependent: :destroy

  # メモのどの部分（属性）を探せるか」を決めている
  def self.ransackable_attributes(_auth_object = nil)
    %w[title content] # タイトルと内容を探せるようにしている
  end

  # メモに関連するどの部分（関連）を探せるかを決めている
  def self.ransackable_associations(_auth_object = nil)
    ['comments'] # コメントを探せるようにしている
  end
end
