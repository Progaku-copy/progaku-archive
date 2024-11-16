# frozen_string_literal: true

module Slack
  class PostersController < ApplicationController
    skip_before_action :authenticate_user!, only: %i[update]

    # PUT /slack/posters/
    # Slack APIからユーザー情報を取得し、DBに保存する(upsert)
    # @return [JSON] ステータスコードのみ返す
    def update
      slack_posters = SlackApiClient.fetch_slack_users
      poster_params = Poster.build_from_slack_posters(slack_posters['members'])
      Poster.import poster_params, on_duplicate_key_update: %i[display_name real_name]
      head :no_content
    end
  end
end
