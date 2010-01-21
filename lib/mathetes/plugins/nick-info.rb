# Keeps track of which nicks are registered with NickServ,
# and whether users are currently identified.

# By Pistos - irc.freenode.net#mathetes

module Mathetes; module Plugins

  class NickInfo

    CHECK_INTERVAL = 60 * 60  # 1 hour

    NickRec = Struct.new( :nick, :registered, :identified, :time_checked )

    include Mathetes::Traited
    trait( :nicks => Hash.new { |h,k|
      h[ k ] = new_nick_rec( k, Time.now - CHECK_INTERVAL )
    } )

    def self.new_nick_rec( nick, time_checked = Time.now )
      NickRec.new( nick, false, false, time_checked )
    end

    def self.[]( nick )
      trait[ :nicks ][ nick ]
    end

    def self.registered?( nick )
      trait[ :nicks ][ nick ].registered
    end

    def self.identified?( nick )
      trait[ :nicks ][ nick ].identified
    end

    def initialize( mathetes )
      @mathetes = mathetes
      mathetes.hook_privmsg do |message|
        handle_privmsg message
      end
      mathetes.hook_notice do |message|
        handle_notice message
      end
    end

    def handle_privmsg( message )
      nick = message.from.nick

      n = NickInfo[ nick ]
      if Time.now - n.time_checked > CHECK_INTERVAL
        @mathetes.say "INFO #{n.nick}", "NickServ"
      end

      if /^!ns ([!-~]+)/ === message.text
        n = NickInfo[ $1 ]
        message.answer "[nick] #{n.nick} - [#{n.registered ? 'R' : '!r'}#{n.identified ? 'I' : '!i'}]"
      end
    end

    def handle_notice( message )
      return  if message.from.nil? || message.from.nick != 'NickServ'
      case message.text
      when /^Information on .{0,5}?([!-~]+)/
        n = $1
        @nick_current = class_trait[ :nicks ][ n ] = NickInfo.new_nick_rec( n )
      when /^([!-~]+) is not registered/
        @nick_current = nil
      when /^Registered : /
        if @nick_current
          @nick_current.registered = true
        end
      when /^Last seen  : now/
        if @nick_current
          @nick_current.identified = true
        end
      end
    end
  end

end; end
