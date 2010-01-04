require 'open-uri'
require 'nokogiri'

module Mathetes; module Plugins

  class Dictionary

    def initialize( mathetes )
      mathetes.hook_privmsg( :regexp => /^;d(ict)?\b/ ) do |message|
        arg = CGI.escape( message.text[ /^\S+\s+(.*)/, 1 ] )
        doc = Nokogiri::HTML(
          open( "http://www.wordsmyth.net/live/home.php?script=search&matchent=#{arg}&matchtype=exact" )
        )


        not_found_p = doc.at( '[name="p"]' )
        if not_found_p && not_found_p.content =~ /Sorry, we could not find/
          suggestions = doc.search( 'a' ).map { |a| a.content }
          output = '(no results)'
          if suggestions.any?
            output << " Close matches: #{suggestions.join( ', ' )}"
          end
          message.answer output

          return
        end

        tables = doc.search( 'table[cellspacing="0"][border="0"][cellpadding="2"][width="100%"]' )
        maintable = tables.find { |t| t[ 'align' ].nil? && t[ 'bgcolor' ].nil? }
        wordtag = maintable.at( 'div.headword' )
        if wordtag
          word = wordtag.children.find_all { |x| x.text? }.map { |t| t.to_s }.join
        end

        output = ""
        maintable.css( 'tr' ).each do |tr|

          main_td = tr.at( 'td[width="70%"]' )
          middle_td = tr.at( 'td[width="5%"][valign="baseline"]' )

          # Part of Speech

          if tr[ 'bgcolor' ] == '#DDDDFF'
            pos = main_td.at( 'span' ).content
            if ! output.empty?
              message.answer output
            end
            output = "#{word} - [#{pos}]"
          end

          if tr[ 'bgcolor' ] == '#FFFFFF'
            # Pronunciation

            prontag = tr.search( 'div.pron' )
            if prontag
              syllabification = []
              prontag.css( 'span' ).each do |syllable|
                next  if syllable.content.empty?

                syllable_class = syllable[ 'class' ]
                if syllable_class
                  stress_level = syllable_class[ /(\d)/, 1 ].to_i
                  case stress_level
                  when 1
                    stress = "'"
                  when 2
                    stress = '"'
                  else
                    stress = ''
                  end
                  syllabification << stress + syllable.content
                else
                  syllabification << syllable.content
                end
              end
              if syllabification.any?
                output << " (" + syllabification.join( ' ' ) + ")"
              end
            end

            # Definition

            if main_td
              def_span = main_td.at( 'span[style="font-weight: normal;"]' )
              if def_span
                output << "  " + middle_td.at( 'span' ).content + " " + def_span.content
              end
            end
          end
        end

        if ! output.empty?
          message.answer output
        end

      end
    end

  end

end; end
