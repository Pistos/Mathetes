module Mathetes; module Plugins

  module WebScrape

    def self.scrape( search_url, regexp, search_term = "", max_results = 1 )
      hits = []

      open( search_url ) do |html|
        text = html.read
        text.scan( regexp ) do |url|
          case url
          when Array
            url.collect! do |u|
              u.gsub( /\n/m, " " ).gsub( /<.+?>/, "" )
            end
          when String
            u.gsub!( /\n/m, " " )
            u.gsub!( /<.+?>/, "" )
          end

          hits << CGI.unescapeHTML( url.to_s )

          break  if hits.size >= max_results
        end
      end

      hits
    end

  end

end; end
