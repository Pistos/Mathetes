require 'cgi'
require 'nokogiri'
require 'open-uri'

module Mathetes; module Plugins

  class GoogleFight
    GOOGLEFIGHT_VERBS = [
      [ 1000.0, "completely DEMOLISHES" ],
      [ 100.0, "utterly destroys" ],
      [ 10.0, "destroys" ],
      [ 5.0, "demolishes" ],
      [ 3.0, "crushes" ],
      [ 2.0, "shames" ],
      [ 1.2, "beats" ],
      [ 1.0, "barely beats" ],
    ]

    def initialize( mathetes )
      mathetes.hook_privmsg(
        :regexp => /^!(googlefight|gf)\b/
      ) do |plugin,message|
        plugin.handle_privmsg message
      end
    end

    def number_with_delimiter( number, delimiter = ',' )
      number.to_s.gsub( /(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}" )
    end

    def google_count( terms )
      terms = CGI.escape( terms )
      doc = Nokogiri::HTML( open( "http://www.google.com/search?q=#{terms}" ) )
      doc.at( '#ssb//b[3]' ).inner_text.gsub( ',', '' ).to_i
    end

    def handle_privmsg( message )
      args = message.text[ /^\S+\s+(.*)/, 1 ]

      a = args.split( /\bv(?:ersu)?s(?:\.|\b)/ )
      if a.size != 2
        a = args.split( /\s+/, 2 )
      end

      nick = message.from.nick

      if a.size != 2
        message.answer "#{nick}: !googlefight <term(s)> [vs | ,] <term(s)>"
      else
        a.collect! { |t| t.strip }
        count1 = google_count( a[ 0 ] )
        count2 = google_count( a[ 1 ] )
        ratio1 = ( count2 != 0 ) ? count1.to_f / count2 : 99
        ratio2 = ( count1 != 0 ) ? count2.to_f / count1 : 99
        ratio = [ ratio1, ratio2 ].max
        verb = GOOGLEFIGHT_VERBS.find { |x| ratio > x[ 0 ] }[ 1 ]
        c1 = number_with_delimiter( count1 )
        c2 = number_with_delimiter( count2 )

        if count1 > count2
          msg = "#{a[0]} #{verb} #{a[1]}! (#{c1} to #{c2})"
        else
          msg = "#{a[1]} #{verb} #{a[0]}! (#{c2} to #{c1})"
        end
        message.answer "#{nick}: #{msg}"
      end
    end

  end

end; end
