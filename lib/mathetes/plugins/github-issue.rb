module Mathetes; module Plugins
  class GitHubIssue
    def initialize( mathetes )
      mathetes.hook_privmsg(
        :regexp => /#[0-9]+/
      ) do |message|
        issues = message.text[ /#([0-9]+)/, 1 ]
	issues.each { |issue| message.answer "https://github.com/openphoto/frontend/issues/#{issue}" }
      end
    end
  end
end; end
