require 'cgi'
require 'open-uri'
require 'nokogiri'

module Mathetes; module Plugins

  class DownForMe

    def initialize( mathetes )
      mathetes.hook_privmsg( :regexp => /^(!(up|down)|(up|down)\?)\b/ ) do |message|
        terms = message.text[ /^\S+\s+(.*)/, 1 ]
        site = terms.downcase[ /([a-z0-9.-]+)($|\/)/, 1 ]
        doc = Nokogiri::HTML( open( "http://downforeveryoneorjustme.com/#{site}" ) )
        message.answer "#{message.from.nick}: [#{site}] " + doc.at( 'div#container' ).children.select{ |e| e.text? }.join( ' ' ).gsub( /\s+/, ' ' ).strip
      end
    end

  end

end; end
