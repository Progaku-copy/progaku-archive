# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

module ApiClient
  def self.fetch_data(base_url, params = {})
    uri = build_uri(base_url, params)
    request = build_request(uri)
    execute_request(uri, request)
  end

  def self.build_uri(base_url, params)
    uri = URI.parse(base_url)
    uri.query = URI.encode_www_form(params) unless params.empty?
    uri
  end

  def self.build_request(uri)
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{ENV.fetch('SLACK_API_TOKEN', nil)}"
    request
  end

  def self.execute_request(uri, request)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end
    handle_response(response)
  end

  def self.handle_response(response)
    if response.is_a?(Net::HTTPSuccess)
      JSON.parse(response.body)
    else
      Rails.logger.debug { "Error: #{response.message}" }
    end
  end
end
