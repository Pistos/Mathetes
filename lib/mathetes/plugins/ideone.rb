require 'ideone'

module Mathetes; module Plugins

  class Ideone

    MAX_RESULT_LENGTH = 300   # characters

    def initialize( mathetes )
      mathetes.hook_privmsg( :regexp => /^!(?:ruby|rb|python|py|perl|pl|php)\b/ ) do |message|
        message.text =~ /^!(\S+)\s+(.*)/
        lang_, code = $1, $2
        case lang_
          when 'ruby', 'rb'
            lang = :ruby
          when 'python', 'py'
            lang = :python
          when 'perl', 'pl'
            lang = :perl
          when 'php'
            lang = :php
        end

        paste_id = ::Ideone.submit( lang, code )
        begin
          stdout = ::Ideone.run( paste_id, nil ).inspect
          if stdout.length > MAX_RESULT_LENGTH
            stdout = stdout[ 0...MAX_RESULT_LENGTH ] + "..."
          end
          message.answer "[code] #{stdout}"
        rescue ::Ideone::IdeoneError => e
          message.answer "[code] #{e.message}"
        end
      end
    end

  end

end; end
