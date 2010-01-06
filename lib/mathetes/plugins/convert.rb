# Uses Google to convert just about anything to anything else (units, currency, etc.)

# By Pistos - irc.freenode.net#geoshell

# Usage:
# !convert <any rough expression about conversion>
# e.g. !convert 20 mph to km/h

require "open-uri"
require "cgi"

module Mathetes; module Plugins

  class Converter
    def initialize( mathetes )
      mathetes.hook_privmsg( :regexp => /^!(conv(ert)?|calc)\b/ ) do |message|
        arg = CGI.escape( message.text[ /^\S+\s+(.*)/, 1 ] )
        open( "http://www.google.com/search?q=#{ arg }" ) do |html|
          answered = false
          html.read.scan /calc_img.+?<b>(.+?)<\/b>/ do |result|
            stripped_result = result[ 0 ]
            stripped_result = stripped_result.gsub( /<sup>(.+?)<\/sup>/, "^(\\1)" )
            stripped_result = stripped_result.gsub( /<font size=-2> <\/font>/, "" )
            stripped_result = stripped_result.gsub( /<[^>]+>/, "" )
            stripped_result = stripped_result.gsub( /&times;/, "x" )
            message.answer stripped_result
            answered = true
            break
          end
          if ! answered
            message.answer "(no results)"
          end
        end
      end
    end
  end

end; end
