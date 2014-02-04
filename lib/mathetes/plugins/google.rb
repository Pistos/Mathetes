require 'cgi'
require 'open-uri'

module Mathetes; module Plugins

  class Google

    MAX_RESULTS = 5

    def initialize( mathetes )
      mathetes.hook_privmsg( :regexp => /^!g(oogle)?\b/ ) do |message|
        args = message.text[ /^\S+\s+(.*)/, 1 ]
        nick = message.from.nick

        num_results = 1
        args_array = args.split( /\s+/ )

        if args_array.length < 1
          message.answer "!google [number of results] <search terms>"
          return
        end

        if args_array[ 0 ].to_i.to_s == args_array[ 0 ]
          # A number of results has been specified
          num_results = args_array[ 0 ].to_i
          if num_results > MAX_RESULTS
            num_results = MAX_RESULTS
          end
          arg = args_array[ 1..-1 ].join( "+" )
          unescaped_arg = args_array[ 1..-1 ].join( " " )
        else
          arg = args_array.join( "+" )
          unescaped_arg = args_array.join( " " )
        end

        arg = CGI.escape( arg )

        open( "https://www.google.com/search?q=#{ CGI.escape( args ) }&safe=active" ) do |html|
          counter = 0
          #html.read.scan /<a class="l" href="?([^"]+)".*?>(.+?)<\/a>/m do |match|
          html.read.scan /<a href="?\/url\?q=([^"&]+).*?".*?>(.+?)<\/a>/m do |match|
            url, title = match
            title.gsub!( /<.+?>/, "" )
            ua = unescaped_arg.gsub( /-?site:\S+/, '' ).strip
            message.answer "[#{ua}]: #{url} - #{title}"
            counter += 1
            break  if counter >= num_results
          end

          if counter == 0
            message.answer "(no results)"
          end
        end
      end
    end

  end

end; end
