require 'cgi'
require 'open-uri'
require 'mathetes/plugins/web-scrape'

module Mathetes; module Plugins

  class Etymology

    def initialize( mathetes )
      mathetes.hook_privmsg( :regexp => /^!etym(ology)?\b/ ) do |message|
        terms = message.text[ /^\S+\s+(.*)/, 1 ]
        arg = CGI.escape( terms )

        hits = WebScrape.scrape(
          "http://www.etymonline.com/index.php?term=#{ arg }",
          /<dt(?: class="highlight")?>(.+?)<\/dd>/m,
          arg
        )

        if hits.empty?
          message.answer "[#{terms}] No results."
        else
          hits.each do |hit|
            message.answer "[#{terms}] #{hit}"
          end
        end

      end
    end

  end

end; end
