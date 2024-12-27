# frozen_string_literal: true

module Slack
  class PostsController < ApplicationController
    skip_before_action :authenticate_user!, only: %i[update]

    # PUT /slack/posts/
    # Slack APIから投稿情報を取得し、投稿をmemos、スレッドをcommentsテーブルに保存する(upsert)
    def update
      slack_channels_data = SlackApiClient.fetch_channels_data
      Memo::SlackImport.import_from_slack_posts(slack_channels_data)
      head :no_content
    end
  end
end
