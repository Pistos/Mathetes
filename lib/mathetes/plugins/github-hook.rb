# This listens for connections from the github-hook server,
# which is running independently, receiving POSTs from github.com.

# By Pistos - irc.freenode.net#mathetes

require 'json'
require 'open-uri'
require 'cgi'
require 'eventmachine'
require 'mutex-pstore'

module Mathetes; module Plugins

  module GitHubHookServer

    # Mapping of repo names to interested channels
    REPOS = {
      'better-benchmark'        => [ '#mathetes', ],
      'buildmybike'             => [ '#ramaze', ],
      'diakonos'                => [ '#mathetes', ],
      'dk-git'                  => [ '#mathetes', ],
      'dk-selector'             => [ '#mathetes', ],
      'epoxy'                   => [ '#ruby-dbi', ],
      'ffi-tk'                  => [ '#ver', ],
      'firewatir-enhancements'  => [ '#mathetes', '#watir' ],
      'github'                  => [ '#mathetes' ],
      'hashpipe'                => [ '#ruby-dbi', ],
      'hoptoad-notifier-ramaze' => [ '#mathetes', '#ramaze' ],
      'ideone-gem'              => [ '#mathetes', ],
      'innate'                  => [ '#mathetes', '#ramaze', ],
      'linistrac'               => [ '#mathetes', '#ramaze', ],
      'm4dbi'                   => [ '#mathetes', '#ruby-dbi', ],
      'Mathetes'                => [ '#mathetes', ],
      'methlab'                 => [ '#ruby-dbi', ],
      'nagoro'                  => [ '#mathetes', '#ramaze' ],
      'Ramalytics'              => [ '#mathetes', '#ramaze' ],
      'Reby'                    => [ '#mathetes', ],
      'rack'                    => [ '#rack', '#ramaze', ],
      'ramaze'                  => [ '#mathetes', '#ramaze', ],
      'ramaze-book'             => [ '#mathetes', '#ramaze' ],
      'ramaze-proto'            => [ '#mathetes', '#ramaze' ],
      'ramaze.net'              => [ '#ramaze', ],
      'ramaze-wiki-pages'       => [ '#mathetes', '#ramaze' ],
      'rdbi'                    => [ '#ruby-dbi', ],
      'rdbi-dbd-mysql'          => [ '#ruby-dbi', ],
      'rdbi-dbd-postgresql'     => [ '#ruby-dbi', ],
      'rdbi-dbd-sqlite3'        => [ '#ruby-dbi', ],
      'rdbi-driver-mock'        => [ '#ruby-dbi', ],
      'rdbi-driver-mysql'       => [ '#ruby-dbi', ],
      'rdbi-driver-postgresql'  => [ '#ruby-dbi', ],
      'rdbi-driver-sqlite3'     => [ '#ruby-dbi', ],
      'rdbi-result-driver-json' => [ '#ruby-dbi', ],
      'ruby-dbi'                => [ '#ruby-dbi', ],
      'rvm'                     => [ '#rvm', ],
      'rvm-site'                => [ '#rvm', ],
      'selfmarks'               => [ '#mathetes', ],
      'sociar'                  => [ '#ramaze' ],
      'Thankful-Eyes'           => [ '#mathetes', ],
      'typelib'                 => [ '#ruby-dbi', ],
      'ver'                     => [ '#ver' ],
      'watir-mirror'            => [ '#mathetes', '#watir' ],
      'weewar-ai'               => [ '#mathetes' ],
      'zepto-url'               => [ '#mathetes', '#ramaze', ],
    }

    def say_rev( rev, message, destination )
      @seen ||= Hash.new
      s = ( @seen[ destination ] ||= Hash.new )
      if ! s[ rev ]
        $mathetes.say( message.gsub( "\n", ' ' ), destination )
        s[ rev ] = true
      end
    end

    def zepto_url( url )
      URI.parse( 'http://zep.purepistos.net/zep/1?uri=' + CGI.escape( url ) ).read
    rescue
      # (return nil)
    end

    def receive_data( data )
      begin
        hash = JSON.parse( data )
      rescue JSON::ParserError => e
        $stderr.puts e.message
        File.open( Time.now.strftime( "github-bad-data-%Y-%m-%d-%H%M.json" ), 'w' ) { |f| f.puts data }
        return
      end

      repo = hash[ 'repository' ][ 'name' ]
      owner = hash[ 'repository' ][ 'owner' ][ 'name' ]
      channels = REPOS[ repo ]

      commits = hash[ 'commits' ]

      if commits.size < 7

        # Announce each individual commit

        commits.each do |cdata|
          author = cdata[ 'author' ][ 'name' ]
          message = cdata[ 'message' ].gsub( /\s+/, ' ' )[ 0..384 ]
          url = zepto_url( cdata[ 'url' ] )
          text = "[\00300github\003] [\00303#{repo}\003] <\00307#{author}\003> #{message} #{url}"

          if channels.nil? || channels.empty?
            $mathetes.say "Unknown repo: '#{repo}'", '#mathetes'
            $mathetes.say text, '#mathetes'
          else
            channels.each do |channel|
              say_rev cdata[ 'id' ], text, channel
            end
          end
        end

      else

        # Too many commits; say a summary only

        authors = commits.map { |c| c[ 'author' ][ 'name' ] }.uniq
        shas = commits.map { |c| c[ 'id' ] }
        first_url = zepto_url( commits[ 0 ][ 'url' ] )
        if channels
          channels.each do |channel|
            @seen ||= Hash.new
            s = ( @seen[ channel ] ||= Hash.new )
            shas.each do |sha|
              s[ sha ] = true
            end
            $mathetes.say "[\00300github\003] [\00303#{repo}\003] #{commits.size} commits by: \00307#{authors.join( ', ' )}\003  #{first_url}", channel
          end
        end

      end

      close_connection
    end
  end

  class GitHubHookReceiver

    BANG_COMMAND = '!github'

    def initialize( mathetes )
      @repos = MuPStore.new( "github-repos.pstore" )

      mathetes.new_thread do
        loop do
          EventMachine::run do
            EventMachine::start_server '127.0.0.1', 9005, GitHubHookServer
          end
          $stderr.puts "*** EventMachine died; restarting ***"
        end
      end

      mathetes.hook_privmsg( :regexp => /^#{BANG_COMMAND}\b/ ) do |message|
        args = message.text[ /^\S+\s+(.*)/, 1 ]
        break  if args.strip.empty?
        args = args.split( /\s+/ )
        case args[ 0 ]
        when 'add', 'sub', 'subscribe'
          if args[ 1 ].nil?
            message.answer "#{BANG_COMMAND} #{args[0]} <github repo name> [#channel]"
          else
            @repos.transaction do
              repo = args[ 1 ]
              @repos[ repo ] ||= Array.new
              channel = args[ 2 ] || message.channel.name
              @repos[ repo ] << channel
              message.answer "#{channel} subscribed to github repository #{repo}."
            end
          end
        when 'list'
          if args[ 1 ].nil?
            message.answer "#{BANG_COMMAND} list <github repo name|#channel>"
          else
            @repos.transaction do
              r = @repos[ args[1] ]
              if r
                message.answer r.join( ' ' )
              else
                repos = []
                @repos.roots.each do |k|
                  if @repos[k].include?( args[1] )
                    repos << @repos[k]
                  end
                end
                if repos.any?
                  message.answer repos.map { |r| r[0] }.join( ', ' )
                else
                  message.answer "No github hook subscriptions found."
                end
              end
            end
          end
        when 'delete', 'del', 'rm', 'remove', 'unsub', 'unsubscribe'
          if args[1].nil?
            message.answer "#{BANG_COMMAND} #{args[0]} <github repo name> [#channel]"
          else
            @repos.transaction do
              repo = @repos[ args[1] ]
              channel = args[2] || message.channel.name
              if repo
                if repo.delete( channel )
                  message.answer "#{channel} unsubscribed from github repository #{repo}."
                else
                  message.answer "#{channel} not subscribed to github repository #{repo}?"
                end
              else
                message.answer "#{channel} not subscribed to github repository #{repo}?"
              end
            end
          end
        end
      end
    end

  end

end; end

