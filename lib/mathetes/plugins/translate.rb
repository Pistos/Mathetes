require 'cgi'
require 'open-uri'
require 'json'

module Mathetes; module Plugins

  class Translate

    # @return The two-letter language code of the language
    def self.detect( s )
      google_response = open( "http://ajax.googleapis.com/ajax/services/language/detect?v=1.0&q=#{CGI.escape(s)}" ) { |h| h.read }
      r = JSON.parse( google_response )
      if r.nil?
        $stderr.puts "Failed to parse JSON for: #{google_response.inspect}"
      end
      if r && r[ 'responseData' ]
        r[ 'responseData' ][ 'language' ]
      end
    end

    # @return The translated text.
    def self.translate( s, lang_source, lang_dest = 'en' )
      google_response = open( "http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&langpair=#{lang_source}%7C#{lang_dest}&q=#{CGI.escape(s)}" ) { |h| h.read }
      r = JSON.parse( google_response )
      if r.nil?
        $stderr.puts "Failed to parse JSON for: #{google_response.inspect}"
      end
      if r && r[ 'responseData' ]
        r[ 'responseData' ][ 'translatedText' ]
      end
    end

    def initialize( mathetes )
      mathetes.hook_privmsg( :regexp => /^!tr(?:ans(?:late)?)?\b/ ) do |message|
        if message.text =~ /^!tr.* ([a-zA-Z-]{2,5}) ([a-zA-Z-]{2,5}) (.+)/
          src, dest, text = $1, $2, $3
          translation = Translate.translate( text, src, dest )
          if translation
            message.answer "[tr] #{translation}"
          end
        else
          $stderr.puts "message doesn't match: #{message.text.inspect}"
        end
      end
    end

  end

end; end
