require 'open-uri'
require 'nokogiri'

module Mathetes; module Plugins

  class Haiku

    def initialize( mathetes )
      mathetes.hook_privmsg( :regexp => /^!haiku\b/ ) do |message|
        haikus = Nokogiri::HTML(
          open "http://www.dailyhaiku.org/haiku/?pg=#{ rand(220) + 1 }"
        ).search( 'p.haiku' ).to_a
        haikus[ rand( haikus.size ) ].text.split( /[\r\n]+/ ).each do |line|
          message.answer line
          sleep 3
        end
      end
    end

  end

end; end
