# This script polls the Twitter API, echoing new messages to IRC.

# By Pistos - irc.freenode.net#mathetes

require 'twitter'
require 'time'
require 'yaml'
require 'rexml/document'
require 'cgi'

module Mathetes; module Plugins

  class Twitter

    CHANNELS = {
      'webbynode' => [ '#webbynode', ],
      'ramazetest' => [ '#mathetes', ],
    }
    SEARCHES = {
      'ramaze' => [ '#ramaze', ],
      'ruby dbi' => [ '#ruby-dbi', ],
      'rdbi' => [ '#ruby-dbi', ],
      'm4dbi' => [ '#ruby-dbi', ],
      'webbynode' => [ '#webbynode', ],
      'nanoc -moritaya -virtualdjradio -warong1' => [ '#nanoc', ],
    }
    POLL_INTERVAL = 180 # seconds
    FILTERS = [
      /^RT /,
      /rubysoftwaredevelopment\.com/,
      /ramaze ruby developers - http:/,
    ]

    def initialize( mathetes )
      @mathetes = mathetes
      config = YAML.load_file 'mathetes-twitter.yaml'
      @twitter = ::Twitter::Base.new(
        ::Twitter::HTTPAuth.new( config[ 'username' ], config[ 'password' ] )
      )
      @last_search_id = Hash.new
      @seen = Hash.new { |hash,key| hash[ key ] = Array.new }

      SEARCHES.each do |search_term,channels|
        search = ::Twitter::Search.new( search_term )
        begin
          fetched = search.fetch
          max_id = fetched[ 'max_id' ].to_i
          @last_search_id[ search_term ] = max_id
          channels.each do |channel|
            @seen[ channel ] << max_id
          end
        rescue Exception => e
          $stderr.puts "Twitter exception: #{e}"
        end
      end

      @mathetes.new_thread do
        loop do
          poll_timeline
          poll_searches
          sleep POLL_INTERVAL
        end
      end
    end

    # The first time this is run, it just gets the most recent tweet and doesn't output it.
    def poll_timeline
      opts = @last_id ? { :since_id => @last_id } : {}
      tl = @twitter.friends_timeline( opts )
      if tl.any?
        if @last_id.nil?
          @last_id = tl[ 0 ].id.to_i
        else
          tl.reverse!
          tl.reverse_each do |tweet|
            say_tweet tweet
          end
        end
      end
    rescue Exception => e
      $stderr.puts "Twitter exception: #{e.message}"
      # $stderr.puts e.backtrace.join( "\t\n" )
    end

    def poll_searches
      SEARCHES.each do |search_term,channels|
        search = ::Twitter::Search.new( search_term )
        last_id = @last_search_id[ search_term ]
        search.since( last_id )
        fetched = search.fetch
        if fetched[ 'max_id' ].to_i > last_id
          @last_search_id[ search_term ] = fetched[ 'max_id' ].to_i
          fetched[ 'results' ].each do |tweet|
            say_search_tweet tweet, channels
          end
        end
      end
    rescue Exception => e
      $stderr.puts "Twitter exception: #{e.message}"
      # $stderr.puts e.backtrace.join( "\t\n" )
    end

    def clean_text( text )
      # converted = text.gsub( /&#([[:digit:]]+);/ ) {
        # [ $1.to_i ].pack( 'U*' )
      # }.gsub( /&#x([[:xdigit:]]+);/ ) {
        # [ $1.to_i(16) ].pack( 'U*' )
      # }
      REXML::Text::unnormalize(
        text.gsub( /&\#\d{3,};/, '?' ).gsub( /\n/, ' ' )
        # converted
      )
      # ).gsub( /[^a-zA-Z0-9,.;:&\#@'!?\/ ()_-]/, '' )
    end

    def say_tweet( tweet )
      tweet_id = tweet.id.to_i
      return  if tweet_id < @last_id
      @last_id = tweet_id
      src = tweet.user.screen_name
      text = clean_text( tweet.text )
      alert = "[\00300twitter\003] <#{src}> #{text}"
      channels = CHANNELS[ src ] || [ 'Pistos' ]
      channels.each do |channel|
        if ! @seen[ channel ].include?( tweet_id )
          @mathetes.say alert, channel
          @seen[ channel ] << tweet_id
          lang, tr = translate( text )
          if lang && tr
            @mathetes.say "[\00300twitter\003] (#{lang}) <#{src}> #{tr}", channel
          end
        end
      end
    end

    def say_search_tweet( tweet, channels = [ 'Pistos' ] )
      tweet_id = tweet[ 'id' ].to_i
      src = tweet[ 'from_user' ]
      text = clean_text( tweet[ 'text' ] )
      if FILTERS.find { |f| f =~ text }
        $stderr.puts "[twitter] Filtered: #{text}"
        return
      end

      alert = "[\00300twitter\003] <#{src}> #{text}"
      channels.each do |channel|
        if ! @seen[ channel ].include?( tweet_id )
          @mathetes.say alert, channel
          @seen[ channel ] << tweet_id
          lang, tr = translate( text )
          if lang && tr
            @mathetes.say "[\00300twitter\003] (#{lang}) <#{src}> #{tr}", channel
          end
        end
      end
    end

    def translate( s )
      return  if ! defined? Mathetes::Plugins::Translate
      lang_source = Translate.detect s
      if lang_source && lang_source != 'en'
        tr = Translate.translate( s, lang_source )
        [ lang_source, tr ]
      end
    end

  end

end; end
