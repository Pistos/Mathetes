require 'mutex-pstore'

module Mathetes; module Plugins

  class LastSpoke

    # Add bot names to this list, if you like.
    IGNORED = [ "", "*" ]

    def initialize( mathetes )
      @mathetes = mathetes

      @last_spoke = MuPStore.new( "lastspoke.pstore" )
      # @last_spoke.ultra_safe = true
      @spoke_start = MuPStore.new( "lastspoke-start.pstore" )
      @spoke_start.transaction { @spoke_start[ 'time' ] = Time.now }

      mathetes.hook_privmsg do |message|
        handle_privmsg message
      end

      mathetes.hook_privmsg( :regexp => /^!(last(spoke)?|spoke)\b/ ) do |message|
        query message
      end
    end

    def seconds_to_interval_string( seconds_ )
      seconds = seconds_.to_i
      minutes = 0
      hours = 0
      days = 0

      if seconds > 59
        minutes = seconds / 60
        seconds = seconds % 60
        if minutes > 59
          hours = minutes / 60
          minutes = minutes % 60
          if hours > 23
            days = hours / 24
            hours = hours % 24
          end
        end
      end

      msg_array = Array.new
      if days > 0
        msg_array << "#{days} day#{days > 1 ? 's' : ''}"
      end
      if hours > 0
        msg_array << "#{hours} hour#{hours > 1 ? 's' : ''}"
      end
      if minutes > 0
        msg_array << "#{minutes} minute#{minutes > 1 ? 's' : ''}"
      end
      if seconds > 0
        msg_array << "#{seconds} second#{seconds > 1 ? 's' : ''}"
      end

      msg_array.join( ", " )
    end

    def handle_privmsg( message )
      nick = message.from.nick
      if ! IGNORED.include?( nick )
        @last_spoke.transaction do
          @last_spoke[ nick ] = [ Time.now, message.channel.name, message.text ]
        end
      end
    end

    def query( message )
      target = message.text[ /^\S+\s+(.*)/, 1 ]

      lst = nil
      @last_spoke.transaction { lst = @last_spoke[ target ] }
      if target == message.from.nick
        message.answer "Um... you JUST spoke, to issue the command.  :)"
      elsif target == @mathetes.nick
        message.answer "I don't watch myself."
      elsif lst.nil?
        message.answer "As far as I know, #{target} hasn't said anything."
        t = nil
        @spoke_start.transaction { t = @spoke_start[ 'time' ] }
        message.answer "I've been watching for #{seconds_to_interval_string( Time.now - t )}."
      else
        interval_string = seconds_to_interval_string( Time.now - lst[ 0 ] )
        message.answer "#{interval_string} ago, #{target} said: '#{lst[ 2 ]}' in #{lst[ 1 ]}."
      end
    end
  end

end; end
