# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

module SlackApiClient
  SLACK_USER_URL = 'https://slack.com/api/users.list'
  SLACK_CHANNEL_BASE_URL = 'https://slack.com/api/conversations.history'
  SLACK_THREAD_BASE_URL = 'https://slack.com/api/conversations.replies'
  private_constant :SLACK_USER_URL, :SLACK_CHANNEL_BASE_URL, :SLACK_THREAD_BASE_URL

  class << self
    def fetch_slack_users
      fetch_data(SLACK_USER_URL)
    end

    def fetch_posts(channel_id)
      fetch_data(SLACK_CHANNEL_BASE_URL, { channel: channel_id })
    end

    def fetch_threads(channel_id, thread_ts)
      fetch_data(SLACK_THREAD_BASE_URL, { channel: channel_id, ts: thread_ts })
    end

    private

    def fetch_data(base_url, params = {})
      uri = URI.parse(base_url)
      uri.query = URI.encode_www_form(params) unless params.empty?
      request = build_authorization_header(uri)
      execute_request(uri, request)
    end

    def build_authorization_header(uri)
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{ENV.fetch('SLACK_API_TOKEN', nil)}"
      request
    end

    def execute_request(uri, request)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(request)
      end
      handle_response(response)
    end

    def handle_response(response)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        logger.error("Slack API Error: #{response.message} (HTTP #{response.code})")
        raise "Slack API Error: #{response.message} (HTTP #{response.code})"
      end
    end
  end
end
