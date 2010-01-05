module Mathetes; module Plugins

  class Spell

    MAX_WORD_LENGTH = 50
    NUM_SUGGESTIONS = 15

    def initialize( mathetes )
      mathetes.hook_privmsg( :regexp => /^;spell\b/ ) do |message|
        catch :done do
          rest = message.text[ /^\S+\s+(.*)/, 1 ]
          if rest.nil?
            message.answer "!spell [language code] word"
            throw :done
          end

          args = rest.split( /\s+/ )
          language = "en"
          word = nil

          case args.length
          when 1
            word = args[ 0 ]
          else
            lang = args[ 0 ].downcase
            word = args[ 1 ]
            case lang
            when "en", "de", "fr", "pt", "es", "it"
              language = lang
            end
          end

          throw :done  if word.nil?

          if word.length > MAX_WORD_LENGTH
            retval = "That's not a real word!  :P"
          else
            word.gsub!( /[^a-zA-Z'-]/, '' )
            #aspell = `echo #{word.escapeQuotes} | /usr/local/bin/aspell -a --sug-mode=bad-spellers --personal=/Users/mtidwell/.aspell.en.pws"`
            aspell = `echo '#{ escape_quotes( word ) }' | aspell -d '#{language}' -a --sug-mode=bad-spellers`

            list = aspell.split( ':' )
            result = list[ 0 ]

            if result =~ /\*$/
              retval = "#{word} is spelled correctly."
            else
              if list[ 1 ]
                words = list[ 1 ].strip.split( "," )
                retval = "'#{word}' is probably one of: #{words[ 0, NUM_SUGGESTIONS ].join( ',' )}"
              else
                retval = "No suggestions for unknown word '#{word}'."
              end
            end
          end

          message.answer retval
        end
      end
    end

  end

end; end
