require 'open-uri'
require 'nokogiri'

module Mathetes; module Plugins

  class Dictionary

    def initialize( mathetes )
      mathetes.hook_privmsg( :regexp => /^!d(ict)?\b/ ) do |message|
        catch :done do
          arg = CGI.escape( message.text[ /^\S+\s+(.*)/, 1 ] )
          doc = Nokogiri::HTML(
            open( "http://www.wordsmyth.net/?level=3&m=wn&ent=#{arg}" )
          )

          not_found_div = doc.at( 'div.list_title' )
          if not_found_div && not_found_div.text =~ /Did you mean this word/
            suggestions = doc.search( 'div.wordlist td a' ).map { |a| a.text }
            output = '(no results)'
            if suggestions.any?
              output << " Close matches: #{suggestions.join( ', ' )}"
            end
            message.answer output

            throw :done
          end

          output = ""

          syllabification = doc.at( 'h3.headword.syl' ).text

          # parts of speech
          poses = []
          pos = nil

          trs = doc.search( 'table.maintable tbody tr' )
          trs.each do |tr|
            case tr[ 'class' ]
            when 'postitle'
              if pos
                poses << pos
              end
              pos = {
                :pos => tr.at( 'td.data a' ).text,
                :defs => [],
              }
            when 'definition'
              pos[ :defs ] << tr.at( 'td.data' ).children[ 0 ].text
            end
          end
          if pos
            poses << pos
          end

          if poses.any?
            output = syllabification
            poses.each do |pos|
              output << "  " << pos[ :pos ] << ": "
              defs = []
              pos[ :defs ].each_with_index { |d,i|
                defs << "#{i+1}. #{d}"
              }
              output << defs.join( ' ' )
            end
            message.answer output
          end
        end
      end
    end

  end

end; end
