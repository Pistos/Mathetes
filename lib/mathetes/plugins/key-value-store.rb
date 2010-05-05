require 'mutex-pstore'

module Mathetes; module Plugins

  class KeyValueStore

    def initialize( mathetes )
      @h = MuPStore.new( "key-value.pstore" )
      mathetes.hook_privmsg( :regexp => /^!i(nfo)?\b/ ) do |message|
        if message.text =~ /^\S+\s+(.+?)=(.+)/
          key, value = $1.strip, $2.strip
          @h.transaction {
            @h[ { :channel => message.channel.to_s, :key => key }.inspect ] = value
          }
          message.answer "Set '#{key}'."
        elsif message.text =~ /^\S+\s+(.+)/
          key = $1.strip
          value = nil
          @h.transaction {
            value = @h[ { :channel => message.channel.to_s, :key => key }.inspect ]
          }
          if value
            message.answer value
          else
            message.answer "No value for key '#{key}'."
          end
        else
          message.answer "Usage: !i key = value    !i key"
        end
      end
    end

  end

end; end
