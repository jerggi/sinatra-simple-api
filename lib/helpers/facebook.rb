#!/usr/bin/env ruby
# encoding:utf-8
require 'net/http'
require 'json'
require 'uri'
require 'pp'

module Facebook
  class << self
    FACEBOOK_API_URL   = 'http://api.facebook.com/'
    QUERY              = 'method/links.getStats?urls=#query#&format=json'
    UNKNOWN            = 'neznámý'

    def respond(url)
      uri_server = URI('http://api.facebook.com/method/links.getStats?urls=' + url + '&format=json')
      resp = Net::HTTP.get_response(uri_server)
      resp.body
    rescue URI::InvalidURIError
      '[]'
    end

    def domain(url)
      url = 'http://' + url if %r{^[a-z]+://}.match(url).nil?
      URI(url).host
    rescue URI::InvalidURIError
      UNKNOWN
    end

    def get_result(url)
      base_domain = like_count = share_count = UNKNOWN
      resp = respond(url)
      if resp.length > 2
        resp_obj = JSON.parse(resp[1...-1])
        like_count = resp_obj["like_count"]
        share_count = resp_obj["share_count"]
        base_domain = domain url
      end
      {
        'host'                 => base_domain, # base domain,
        'url'                  => url,
        'like_count'           => like_count, # like_count
        'share_count'          => share_count # share_count#
      }
    end
  end
end
