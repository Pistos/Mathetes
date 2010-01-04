require 'm4dbi'

module Mathetes; module Plugins

  class MemoManager
    # Add bot names to this list, if you like.
    IGNORED = [
        "",
        "*",
        "Gherkins",
        "Mathetes",
        "GeoBot",
        "scry",
    ]
    MAX_MEMOS_PER_PERSON = 20
    PUBLIC_READING_THRESHOLD = 2

        # $reby.bind( "join", "-", "*", "on_join", "$reby_memo" )

    def initialize( mathetes )
      @mathetes = mathetes
      @mathetes.hook_privmsg(
        :regexp => /^;memo\b/
      ) do |message|
        record_memo message
      end
      @mathetes.hook_privmsg do |message|
        handle_privmsg message
      end
      @mathetes.hook_join do |listener,message|
        handle_join message
      end

      @dbh = DBI.connect( "DBI:Pg:reby-memo", "memo", "memo" )
    end

    def memos_for( recipient )
      @dbh.select_all(
        %{
          SELECT
            m.*,
            age( NOW(), m.time_sent )::TEXT AS sent_age
          FROM
            memos m
          WHERE
            (
              lower( m.recipient ) = lower( ? )
              OR ? ~* m.recipient_regexp
            )
            AND m.time_told IS NULL
        },
        recipient,
        recipient
      )
    end

    def record_memo( privmsg )
      args = privmsg.text[ /^\S+\s+(.*)/, 1 ]

      sender = nick = privmsg.from.nick
      recipient, message = args.split( /\s+/, 2 )

      if sender.nil? || recipient.nil? || message.nil? || recipient.empty? || message.empty?
        privmsg.answer "#{nick}: !memo <recipient> <message>"
        return
      end

      if recipient =~ %r{^/(.*)/$}
        recipient_regexp = Regexp.new $1
        @dbh.do(
          "INSERT INTO memos ( sender, recipient_regexp, message ) VALUES ( ?, ?, ? )",
          sender,
          recipient_regexp.source,
          message
        )
        privmsg.answer "#{nick}: Memo recorded for /#{recipient_regexp.source}/."
      else
        if memos_for( recipient ).size >= MAX_MEMOS_PER_PERSON
          privmsg.answer "The inbox of #{recipient} is full."
        else
          @dbh.do(
            "INSERT INTO memos ( sender, recipient, message ) VALUES ( ?, ?, ? )",
            sender,
            recipient,
            message
          )
          privmsg.answer "#{nick}: Memo recorded for #{recipient}."
        end
      end
    end

    def handle_privmsg( message )
      nick = message.from.nick
      return  if IGNORED.include?( nick )

      memos = memos_for( nick )
      if memos.size <= PUBLIC_READING_THRESHOLD
        dest = message.channel.name
      else
        dest = nick
      end

      memos.each do |memo|
        age = memo[ 'sent_age' ].gsub( /\.\d+$/, '' )
        case age
        when /^00:00:(\d+)/
          age = "#{$1} seconds"
        when /^00:(\d+):(\d+)/
          age = "#{$1}m #{$2}s"
        else
          age.gsub( /^(.*)(\d+):(\d+):(\d+)/, "\\1 \\2h \\3m \\4s" )
        end
        @mathetes.say( "#{nick}: [#{age} ago] <#{memo['sender']}> #{memo['message']}", dest )
        @dbh.do(
          "UPDATE memos SET time_told = NOW() WHERE id = ?",
          memo[ 'id' ]
        )
      end
    end

    def handle_join( message )
      nick = message.from.nick
      @mathetes.say "#{nick} joined.", '#mathetes'
      memos = memos_for( nick )
      if memos.size > 0
        put "You have #{memos.size} memo(s).  Speak publicly in a channel to retrieve them.", nick
      end
    end

  end

end; end
