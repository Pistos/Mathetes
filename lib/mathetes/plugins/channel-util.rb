module Mathetes; module Plugins

  class Op

    def initialize( mathetes )
      @mathetes = mathetes
      mathetes.hook_privmsg( :regexp => /^!op\b/ ) do |message|
        $stderr.puts "hey"
        c = message.channel
        if c
          @mathetes.say "OP #{ c }", 'ChanServ'
        end
      end
    end

  end

end; end
