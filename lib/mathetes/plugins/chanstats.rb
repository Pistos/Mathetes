# Maintains some basic stats for channels

# By Pistos - irc.freenode.net#mathetes

require 'yaml'
require 'fileutils'

module Mathetes; module Plugins

  class ChanStats

    DATA_FILE = 'chanstats.dat'
    EXCLUDED_CHANNELS = [ '#sequel', '#ruby-pro' ]

    def initialize( mathetes )
      @mathetes = mathetes

      mathetes.hook_join do |message|
        on_join message
      end

      mathetes.hook_privmsg( :regexp => /^!cs\b/ ) do |message|
        arg = message.text[ /^\S+\s+(.*)/, 1 ]
        channel = message.channel.name
        case arg
        when /^rec/i
          cs = set_defaults( channel )
          n = cs[ :size_record ]
          message.answer "#{channel} had #{n} members on #{cs[:date][n]}."
        end
      end

      load_data
    end

    def set_defaults( channel )
      @stats[ channel ] ||= Hash.new
      @stats[ channel ][ :size_record ] ||= 0
      @stats[ channel ][ :members ] ||= { 0 => [] }
      @stats[ channel ][ :date ] ||= { 0 => Time.now }
      save_data
      @stats[ channel ]
    end

    def on_join( message )
      channel = message.channel.name
      members = message.channel.users.map { |u| u.nick }
      n = members.size
      cs = set_defaults( channel )
      if n > cs[ :size_record ]
        cs[ :size_record ] = n
        cs[ :members ][ n ] = members
        cs[ :date ][ n ] = Time.now
        save_data
        if ! EXCLUDED_CHANNELS.include?( channel )
          @mathetes.say "*** New size record for #{channel}!  #{n} members!  Previous record: #{n-1} set on #{cs[ :date ][ n-1 ]}", channel
        end
      end
    end

    def load_data
      if File.exist? DATA_FILE
        @stats = YAML::load( File.read( DATA_FILE ) )
        if ! @stats
          $stderr.puts "Failed to load stats file!"
        end
      else
        @stats = Hash.new
        save_data
      end
    end

    def save_data
      File.open( DATA_FILE, 'w' ) do |f|
        f.write @stats.to_yaml
      end
    end

  end
end;end
