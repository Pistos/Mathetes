module Mathetes; module Plugins
  class Sample
    def initialize( mathetes )
      mathetes.hook_privmsg(
        :regexp => /#[0-9]+/
      ) do |message|
        issues = message.text[ /#([0-9]+)/, 1 ]
	issues.each { |issue| message.answer "https://github.com/openphoto/frontend/issues/#{issue}" }
        #handle_privmsg message
      end
    end

    def handle_privmsg( message )
      message.answer "Foo to you!"
    end
  end
end; end
