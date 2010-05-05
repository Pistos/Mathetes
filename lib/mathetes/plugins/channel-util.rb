module Mathetes; module Plugins

  class ChannelUtil

    ADMINS = [
      'Pistos',
    ]

    def initialize( mathetes )
      @mathetes = mathetes

      mathetes.hook_privmsg( :regexp => /^!op\b/ ) do |message|
        c = message.channel
        if c
          @mathetes.say "OP #{ c }", 'ChanServ'
        end
      end

      mathetes.hook_privmsg( :regexp => /^!join (#[A-z0-9_-]+)/ ) do |message|
        channel = SilverPlatter::IRC::Channel.new( $1 )
        break  if ! ADMINS.include?( message.from.nick )
        @mathetes.join_channels( [ channel ] )
      end

      mathetes.hook_privmsg( :regexp => /^!part (#[A-z0-9_-]+)/ ) do |message|
        channel = SilverPlatter::IRC::Channel.new( $1 )
        break  if ! ADMINS.include?( message.from.nick )
        @mathetes.part_channels( [ channel ] )
      end
    end

  end

end; end
