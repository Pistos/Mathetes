module Mathetes; module Plugins
  class Sample
    def initialize( mathetes )
      mathetes.hook_privmsg(
        :plugin => self,
        :regexp => /^!foo\b/
      ) do |plugin,message|
        plugin.handle_privmsg message
      end
    end

    def handle_privmsg( message )
      message.answer "Foo to you!"
    end
  end
end; end
