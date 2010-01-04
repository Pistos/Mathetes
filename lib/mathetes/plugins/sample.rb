module Mathetes; module Plugins
  class Sample
    def initialize( mathetes )
      mathetes.hook_privmsg(
        :regexp => /^!foo\b/
      ) do |message|
        handle_privmsg message
      end
    end

    def handle_privmsg( message )
      message.answer "Foo to you!"
    end
  end
end; end
