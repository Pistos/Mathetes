require 'silverplatter/log'
require 'silverplatter/irc/connection'

require 'mathetes'

require 'pp'

module Mathetes
  class IRCBot
    def initialize
      @irc = SilverPlatter::IRC::Connection.new "irc.freenode.net"
      reset
      puts "Initialized."
    end

    def reset
      puts "Resetting..."
      initialize_hooks
      initialize_plugins
      puts "Reset."
    end

    def initialize_hooks
      @hooks = {
        :PRIVMSG => Array.new,
      }
    end

    def initialize_plugins
      load 'mathetes/plugins/sample.rb'
      load 'mathetes/plugins/google-fight.rb'

      Plugins.constants.each do |cname|
        constant = Plugins.const_get( cname )
        if constant.respond_to?( :new )
          constant.new( self )
        end
      end
    end

    def start
      puts "Starting... "

      @irc.connect
      @irc.login( 'Mathetes2', 'Mathetes', 'Mathetes Christou' )
      @irc.send_join "#mathetes"

      puts "Startup complete."

      @irc.read_loop do |message|
        case message.symbol
        when :PRIVMSG
          @hooks[ :PRIVMSG ].each do |h|
            if h.regexp.nil? || h.regexp =~ message.text
              h.call( h.plugin, message )
            end
          end
        end
      end
    end

    def say( message, destination )
      @irc.send_privmsg( message, destination )
    end

    def hook_privmsg( args, &block )
      @hooks[ :PRIVMSG ] << Hooks::PRIVMSG.new( args, &block )
    end
  end
end

$mathetes = Mathetes::IRCBot.new
$mathetes.start
