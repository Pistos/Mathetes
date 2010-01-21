require 'silverplatter/log'
require 'silverplatter/irc/connection'

require 'mathetes'
require 'traited'
require 'yaml'
require 'pp'

Thread.abort_on_exception = true

def escape_quotes( s )
  temp = ""
  s.each_byte do |b|
    if b == 39
      temp << 39
      temp << 92
      temp << 39
    end
    temp << b
  end
  temp
end

module Mathetes
  class IRCBot
    def initialize
      @irc = SilverPlatter::IRC::Connection.new(
        "irc.freenode.net",
        :log => SilverPlatter::Log.to_console( :formatter => SilverPlatter::Log::ColoredDebugConsole )
      )
      reset
      puts "Initialized."
    end

    def reset
      puts "Resetting..."

      kill_threads
      unsubscribe_listeners
      parted = part_channels
      @conf = YAML.load_file 'mathetes-config.yaml'
      initialize_hooks
      initialize_plugins
      join_channels parted

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

    def part_channels
      if @irc.connected?
        channels = @irc.channels.channels
        @irc.send_part 'Parting.', *channels
      end
      channels || []
    end

    def initialize_hooks
      @hooks = {
        :PRIVMSG => Array.new,
        :NOTICE => Array.new,
        :JOIN => Array.new,
      }
    end

    def initialize_plugins
      @conf[ 'plugins' ].each do |plugin|
        begin
          load "mathetes/plugins/#{plugin}.rb"
        rescue Exception => e
          $stderr.puts "Plugin load error: #{e.message}"
          $stderr.puts e.backtrace.join( "\n\t" )
        end
      end

      Plugins.constants.each do |cname|
        constant = Plugins.const_get( cname )
        if constant.respond_to?( :new )
          constant.new( self )
        end
      end
    end

    def join_channels( channels = [] )
      channels.each do |c|
        @irc.send_join c.name
        channel = @conf[ 'channels' ].find { |ch| ch[ 'name' ] == c.name }
        if channel && channel[ 'ops' ]
          @irc.send_privmsg "OP #{ channel[ 'name' ] }", 'ChanServ'
        end
      end
    end

    def start
      puts "Starting... "

      File.open( 'mathetes.pid', 'w' ) do |f|
        f.puts Process.pid
      end

      @irc.connect
      @irc.login( @conf[ 'nick' ], 'Mathetes', 'Mathetes Christou' )
      @irc.send_privmsg "IDENTIFY #{ @conf[ 'password' ] }", 'NickServ'
      @conf[ 'channels' ].each do |channel|
        @irc.send_join channel[ 'name' ]
        if channel[ 'ops' ]
          @irc.send_privmsg "OP #{ channel[ 'name' ] }", 'ChanServ'
        end
      end

      puts "Startup complete."

      @irc.read_loop do |message|
        case message.symbol
        when :PRIVMSG, :NOTICE
          @hooks[ message.symbol ].each do |h|
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

    def ban( user, channel, seconds = 24 * 60 * 60 )
      @irc.send_raw( 'MODE', channel, '+b', user.hostmask.to_s )
      Thread.new do
        sleep seconds
        @irc.send_raw( 'MODE', channel, '-b', user.hostmask.to_s )
      end
    end

    def kick( *args )
      @irc.send_kick *args
    end

    def nick
      @conf[ 'nick' ]
    end

    # --------------------------------------------

    def hook_notice( args = {}, &block )
      @hooks[ :NOTICE ] << Hooks::NOTICE.new( args, &block )
    end

    def hook_privmsg( args = {}, &block )
      @hooks[ :PRIVMSG ] << Hooks::PRIVMSG.new( args, &block )
    end

    def hook_join( &block )
      listener = @irc.subscribe( :JOIN ) do |listener,message|
        block.call( message )
      end
      @hooks[ :JOIN ] << listener
    end

    def new_thread( &block )
      t = Thread.new do
        begin
          block.call
        rescue Exception => e
          $stderr.puts "Exception in thread: #{e.class}: #{e}"
          $stderr.puts e.backtrace.join( "\n\t" )
        end
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
