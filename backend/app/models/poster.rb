# frozen_string_literal: true

# == Schema Information
#
# Table name: posters
#
#  id                              :bigint           not null, primary key
#  display_name(slack上での表示名) :string(255)
#  real_name(slack上での本名)      :string(255)
#  user_key(slack上でのuser.id)    :string(255)      not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#
# Indexes
#
#  index_posters_on_user_key  (user_key) UNIQUE
#
class Poster < ApplicationRecord
  has_many :memos, dependent: :destroy
  has_many :comments, dependent: :destroy
  validates :user_key, presence: true, uniqueness: true

  # Slack APIから取得したユーザー情報からdisplay_nameとreal_nameを取得し、Posterインスタンスを生成する
  # @param posters [Array<Hash>] Slack APIから取得したユーザー情報
  # @return true: Posterの取り込みに成功, false: Posterの取り込みに失敗

  # rubocop:disable Metrics/MethodLength
  def self.build_from_slack_posters
    result = SlackApiClient.fetch_slack_users
    posters = result['members']
    default_name = 'unknown'

    poster_params = posters.filter_map do |poster|
      next if poster['id'].blank?

      new(
        user_key: poster['id'],
        display_name: poster.dig('profile', 'display_name').presence || default_name,
        real_name: poster['real_name'].presence || default_name
      )
    end
    Poster.import! poster_params, on_duplicate_key_update: %i[display_name real_name]
    true
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.debug e.message
    false
  end
  # rubocop:enable Metrics/MethodLength
end
