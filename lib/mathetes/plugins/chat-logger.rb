# chat-logger.rb

# Logs public chatter into log files.

# By Pistos - irc.freenode.net#mathetes

require 'logger'

module Mathetes; module Plugins

  class ChatLogger

    CHANNELS = {
      '#lzracing' => 'log-server/public/lzracing.log',
    }

    def initialize( mathetes )
      @loggers = Hash.new
      CHANNELS.each do |channel,filename|
        @loggers[channel] = Logger.new( filename, 'daily' )
        @loggers[channel].formatter = proc { |severity, datetime, progname, msg|
          t = (datetime - 60 * 60).strftime( "%b %d %H:%M:%S" )
          "[#{t}] #{msg}\n"
        }
      end

      mathetes.hook_privmsg do |message|
        catch :done do
          nick = message.from.nick
          speech = message.text
          channel = message.channel
          throw :done  if channel.nil?

          log = @loggers[channel.name.downcase]
          throw :done  if log.nil?

          if speech =~ /^\001ACTION (.+)\001$/
            log.info "* #{nick} #{$1}"
          else
            log.info "<#{nick}> #{speech}"
          end
        end
      end
    end

  end

end; end
