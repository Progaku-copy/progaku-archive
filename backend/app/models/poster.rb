# frozen_string_literal: true

class Poster < ApplicationRecord
  has_many :memos, dependent: :destroy
  has_many :comments, dependent: :destroy
  validates :user_key, presence: true, uniqueness: true

  def self.build_from_slack_posters(posters)
    default_name = 'unknown'

    posters.map do |poster|
      next if poster['id'].blank?

      new(
        user_key: poster['id'],
        display_name: poster.dig('profile', 'display_name').presence || default_name,
        real_name: poster['real_name'].presence || default_name
      )
    end
  end
end
