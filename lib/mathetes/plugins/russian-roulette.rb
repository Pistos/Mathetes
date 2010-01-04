# russian-roulette.rb

# Kicks people based on public PRIVMSG regexps.

# By Pistos - irc.freenode.net#mathetes

module Mathetes; module Plugins

  class RussianRoulette
    REASONS = [
        'You just shot yourself!',
        'Suicide is never the answer.',
        'If you wanted to leave, you could have just said so...',
        "Good thing these aren't real bullets...",
        "That's gotta hurt...",
    ]
    ALSO_BAN = true
    BAN_TIME = 1 # minutes

    def initialize( mathetes )
      @mathetes = mathetes
      @mathetes.hook_privmsg(
        :regexp => /^!roul\b/
      ) do |message|
        pull_trigger message
      end
    end

    def pull_trigger( message )
      message.answer '*spin* ...'
      sleep 4
      has_bullet = ( rand( 6 ) == 0 )
      if ! has_bullet
        message.answer "-click-"
      else
        if ALSO_BAN
          # @mathetes.ban(
            # message.channel,
            # message.from.nick,
            # "RussianRoulette",
            # "Russian Roulette; for #{BAN_TIME} minute(s).",
            # BAN_TIME
          # )
        end

        @mathetes.kick(
          message.from,
          message.channel,
          '{ *BANG* ' +
            REASONS[ rand( REASONS.size ) ] +
          '}'
        )
      end
    end

  end

end; end
