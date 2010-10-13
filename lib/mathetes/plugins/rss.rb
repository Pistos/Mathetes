# This script polls RSS feeds, echoing new items to IRC.

# By Pistos - irc.freenode.net#mathetes

require 'mvfeed'

module Mathetes; module Plugins

  class RSS

    FEEDS = {
      'http://forum.webbynode.com/rss.php' => {
        :channels => [ '#webbynode', ],
        :interval => 60 * 30,
      },
      'http://blog.webbynode.com/feed/rss/' => {
        :channels => [ '#webbynode', ],
        :interval => 60 * 60,
      },
      'http://status.webbynode.com/feed/' => {
        :channels => [ '#webbynode', ],
        :interval => 60 * 60,
      },
      'http://groups.google.com/group/ramaze/feed/rss_v2_0_msgs.xml' => {
        :channels => [ '#ramaze', ],
        :interval => 60 * 60,
      },
      'http://groups.google.com/group/nanoc/feed/rss_v2_0_msgs.xml' => {
        :channels => [ '#nanoc', ],
        :interval => 60 * 60,
      },
      'http://www.google.com/alerts/feeds/13535865067391668311/1085272382843306248' => {
        :channels => [ '#ramaze', ],
        :interval => 60 * 60,
      },
      'http://projects.stoneship.org/trac/nanoc/timeline?ticket=on&milestone=on&wiki=on&max=50&daysback=90&format=rss' => {
        :channels => [ '#nanoc', ],
        :interval => 5 * 60,
      },
      'http://groups.google.com/group/diaspora-dev/feed/rss_v2_0_msgs.xml' => {
        :channels => [ '#diaspora-dev' ],
        :interval => 15 * 60,
      },
    }

    def initialize( mathetes )
      @mathetes = mathetes
      @seen = Hash.new { |hash,key| hash[ key ] = Hash.new }
      @first = Hash.new { |hash,key| hash[ key ] = true }

      FEEDS.each do |uri, data|
        mathetes.new_thread do
          loop do
            poll_feed( uri, data )
            sleep data[ :interval ]
          end
        end
      end
    end

    def poll_feed( uri, data )
      feed = Feed.parse( uri )
      feed.children.each do |item|
        say_item uri, item, data[ :channels ]
      end
      @first[ uri ] = false
    rescue Exception => e
      $stderr.puts "RSS plugin exception: #{e.message}"
      $stderr.puts e.backtrace.join( "\n\t" )
    end

    def zepto_url( url )
      URI.parse( 'http://z.pist0s.ca/zep/1?uri=' + CGI.escape( url ) ).read
    end

    def say_item( uri, item, channels )
      return  if ! item.respond_to? :link

      if item.respond_to?( :author ) && item.author
        author = "<#{item.author}> "
      end

      alert = nil

      channels.each do |channel|
        id = item.link
        if ! @seen[ channel ][ id ]
          if ! @first[ uri ]
            if alert.nil?
              url = item.link
              if url.length > 28
                url = zepto_url( item.link )
              end
              alert = "[\00300rss\003] #{author}#{item.title} - #{url}"
            end
            @mathetes.say alert, channel
          end
          @seen[ channel ][ id ] = true
        end
      end
    end
  end

end; end
