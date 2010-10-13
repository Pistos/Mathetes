require 'open-uri'
require 'nokogiri'

module Mathetes
  module Plugins
    class Commit
      def initialize(mathetes)
        mathetes.hook_privmsg(:regexp => /^!commit\b/) do |msg|
          open 'http://whatthecommit.com/' do |io|
            msg.answer Nokogiri::HTML(io).css('#content > p').text.strip
          end
        end
      end
    end
  end
end
