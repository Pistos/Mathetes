# Soviet Russia plugin
# See http://en.wikipedia.org/wiki/Russian_reversal#Russian_reversal

# By Pistos - irc.freenode.net#mathetes

require 'russian-reversal'

module Mathetes; module Plugins

  class SovietRussia

    BANG_COMMAND = '!sr'
    DEFAULT_INTERVAL = 30 * 60  # seconds
    # Add bot names to this list, if you like.
    IGNORED = [ "", "*" ]

    def channel_init( channel )
      @channels.transaction do
        @channels[channel] ||= {
          :active => false,
          :interval => DEFAULT_INTERVAL,
          :last => 0,
        }
      end
    end

    def initialize( mathetes )
      @channels = MuPStore.new( "soviet-russia.pstore" )

      mathetes.hook_privmsg do |message|
        handle_privmsg message
      end

      mathetes.hook_privmsg( :regexp => /^#{BANG_COMMAND}\b/ ) do |message|
        args = message.text[ /^\S+\s+(.*)/, 1 ]
        break  if args.strip.empty?
        args = args.split( /\s+/ )
        channel = message.channel.name.downcase
        channel_init( channel )

        case args[ 0 ]
        when 'off'
          @channels.transaction do
            @channels[channel][:active] = false
          end
          message.answer "Soviet Russia mode deactivated for #{channel}."
        when 'on'
          @channels.transaction do
            @channels[channel][:active] = true
          end
          message.answer "Soviet Russia mode activated for #{channel}."
        when /^int/
          int = ( args[1].to_i * 60 )
          @channels.transaction do
            @channels[channel][:interval] = int
          end
          message.answer "Soviet Russia interval for #{channel} set to #{ int / 60.0 } minutes."
        when 'test'
          begin
            reversal = RussianReversal.reverse( args[1..-1].join(' ') )
            if reversal && ! reversal.strip.empty?
              message.answer "HA!  In Soviet Russia, #{reversal} YOU!"
            else
              message.answer "Nothing like that happens in Soviet Russia."
            end
          rescue Exception => e
            message.answer e.message
          end
        end
      end
    end

    def handle_privmsg( message )
      return  if message.channel.nil?
      nick = message.from.nick
      if ! IGNORED.include?( nick )
        channel = message.channel.name.downcase
        channel_init channel
        @channels.transaction do
          delta = Time.now.to_i - @channels[channel][:last]
          if @channels[channel][:active] && delta > @channels[channel][:interval]
            begin
              reversal = RussianReversal.reverse( message.text )
              if reversal && ! reversal.strip.empty?
                message.answer "HA!  In Soviet Russia, #{reversal} YOU!"
                @channels[channel][:last] = Time.now.to_i
              else
                $stderr.puts %{No SR for "#{message}"}
              end
            rescue Exception => e
              $stderr.puts e.message
              $stderr.puts e.backtrace.join("\n\t")
            end
          end
        end
      end
    end

  end

end; end

