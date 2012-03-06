module Mathetes; module Plugins
  class PluginsHelp
    def initialize( mathetes )
      mathetes.hook_privmsg(
        :regexp => /^!help\b/
      ) do |message|
        handle_privmsg message
      end
    end

    def handle_privmsg( message )
      message.answer "There's !d for dictionary.  !memo to leave messages.  !down to check if a site is down for you or everyone.  !last to see when a user last talked in the channel."
    end
  end
end; end
