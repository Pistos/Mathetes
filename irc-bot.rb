require 'silverplatter/log'
require 'silverplatter/irc/connection'

module Mathetes
  class IRCBot
    def initialize
      @irc = SilverPlatter::IRC::Connection.new "irc.freenode.net"
    end

    def start
      @irc.connect
      @irc.login( 'Mathetes2', 'Mathetes', 'Mathetes Christou' )
      @irc.send_join "#mathetes"

      @irc.read_loop do |message|
        case message.symbol
        when :PRIVMSG
          handle_privmsg message
        end
      end
    end

    def say( message, destination )
      @irc.send_privmsg( message, destination )
    end

    def handle_privmsg( m )
      case m.text
      when /^!foo/
        say "Foo to you!", '#mathetes'
      end
    end
  end
end

$mathetes = Mathetes::IRCBot.new
$mathetes.start
