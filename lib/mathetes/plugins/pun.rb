require 'open-uri'
require 'nokogiri'

module Mathetes; module Plugins

  class Pun

    def initialize( mathetes )
      mathetes.hook_privmsg( :regexp => /^!pun\b/ ) do |message|
        doc = Nokogiri::HTML( open( "http://www.punoftheday.com/cgi-bin/randompun.pl" ) )
        message.answer doc.search( '#main-content p' )[ 0 ].inner_text
      end
    end

  end

end; end
