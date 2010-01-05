# kicker.rb

# Kicks people based on public PRIVMSG regexps.

# By Pistos - irc.freenode.net#mathetes

require "open-uri"
require "cgi"

module Mathetes; module Plugins

  class Kicker

    CHANNELS = [
      "#mathetes",
      '#christian',
    ]
    WATCHLIST = {
      'scry' => [
        {
          :regexps => [
            /^(\S+): chamber \d of \d => \*BANG\*/
          ],
          :reasons => [
            'You just shot yourself!',
            'Suicide is never the answer.',
            'If you wanted to leave, you could have just said so...',
            "Good thing these aren't real bullets...",
          ],
        },
      ],
      /.+/ => [
        # {
          # :regexps => [
            # %r{http://TheBibleGeek\.org},
            # %r{http://webulite\.com},
          # ],
          # :reasons => [
            # "You've mentioned that URL enough times.  Please restrict further advertisement of it to private messages.  Thank you.",
          # ],
        # },
        {
          :regexps => [
            /kickme/,
            /\banus\b/i,
            /\bcock\b/i,
            /\bfag\b/i,
            /\bgive me head\b/i,
            /\bnigga\b/i,
            /\bnigger\b/i,
            /\btits\b/i,
            /\btitties\b/i,
            /\bturds?\b/i,
            /\bmy wang\b/i,
            /anal sex/i,
            /asshole/i,
            /my balls/i,
            /bitch/i,
            /blow ?job/i,
            /cunt/i,
            /dick/i,
            /dumbass/i,
            /fuck/i,
            /masturbat/i,
            /oral sex/i,
            /orgasm/i,
            /penis/i,
            /pussy/i,
            /pussies/i,
            /shit/i,
            /suck my/i,
            /vagina/i,
          ],
          :reasons => [
            'Watch your language.',
            'Watch your mouth.',
            'Go wash your mouth out with soap.',
            'Keep it clean.',
            "Don't be vulgar.",
            'No foul language.',
            'No vulgarity.',
          ],
          :exempted => [
            'Pistos',
            'Grace',
            'scry',
            'Gherkins',
            'MathetesUnloved',
            'SpyBot',
          ]
        }
      ],
    }

    def initialize( mathetes )
      mathetes.hook_privmsg do |message|
        catch :done do
          nick = message.from.nick
          speech = message.text
          channel = message.channel
          throw :done  if ! CHANNELS.find { |c| c.downcase == channel.name.downcase }

          WATCHLIST.each do |watch_nick, watchlist|
            next  if ! watch_nick === nick

            watchlist.each do |watch|
              watch[ :regexps ].each do |r|
                next  if r !~ speech

                victim = $1 || nick
                if ! watch[ :exempted ] || ! watch[ :exempted ].include?( victim )
                  reasons = watch[ :reasons ]
                  mathetes.kick(
                    victim,
                    channel,
                    reasons[ rand( reasons.size ) ]
                  )
                  throw :done
                end
              end
            end
          end
        end
      end
    end

  end

end; end
