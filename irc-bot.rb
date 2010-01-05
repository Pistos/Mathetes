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
      kill_threads
      unsubscribe_listeners
      initialize_hooks
      initialize_plugins
      puts "Reset."
    end

    def kill_threads
      if @threads
        @threads.each do |t|
          t.kill
        end
      end
      @threads = Array.new
    end

    def unsubscribe_listeners
      return  if @hooks.nil?
      @hooks[ :JOIN ].each do |hook|
        @irc.unsubscribe hook
      end
    end

    def initialize_hooks
      @hooks = {
        :PRIVMSG => Array.new,
        :JOIN => Array.new,
      }
    end

    def initialize_plugins
      load 'mathetes/plugins/dictionary.rb'
      load 'mathetes/plugins/down-for-me.rb'
      load 'mathetes/plugins/etymology.rb'
      load 'mathetes/plugins/google.rb'
      load 'mathetes/plugins/google-fight.rb'
      load 'mathetes/plugins/memo.rb'
      load 'mathetes/plugins/pun.rb'
      load 'mathetes/plugins/russian-roulette.rb'
      load 'mathetes/plugins/sample.rb'

      Plugins.constants.each do |cname|
        constant = Plugins.const_get( cname )
        if constant.respond_to?( :new )
          constant.new( self )
        end
      end
    end

    def start
      puts "Starting... "

      File.open( 'mathetes.pid', 'w' ) do |f|
        f.puts Process.pid
      end

      @irc.connect
      @irc.login( 'Mathetes2', 'Mathetes', 'Mathetes Christou' )
      @irc.send_join "#mathetes"

      puts "Startup complete."

      @irc.read_loop do |message|
        case message.symbol
        when :PRIVMSG
          @hooks[ :PRIVMSG ].each do |h|
            if h.regexp.nil? || h.regexp =~ message.text
              h.call( message )
            end
          end
        end
      end
    end

    # --------------------------------------------

    def say( message, destination )
      @irc.send_privmsg( message, destination )
    end

    def ban( *args )
      @irc.send_ban *args
    end

    def kick( *args )
      @irc.send_kick *args
    end

    # --------------------------------------------

    def hook_privmsg( args = {}, &block )
      @hooks[ :PRIVMSG ] << Hooks::PRIVMSG.new( args, &block )
    end

    def hook_join( &block )
      listener = @irc.subscribe( :JOIN ) do |listener,message|
        block.call( listener, message )
      end
      @hooks[ :JOIN ] << listener
    end

    def new_thread( &block )
      t = Thread.new do
        block.call
      end
      @threads << t
      t
    end

  end
end

$mathetes = Mathetes::IRCBot.new

Signal.trap( 'HUP' ) do
  $mathetes.reset
end

$mathetes.start
