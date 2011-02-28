require 'time'
require 'date'

module Mathetes; module Plugins
  class TimePlugin
    DEFAULT_TIMEZONE = 'UTC'
    ANSWER = "The current time in %Z is %H:%M. The date is %m/%d/%Y"
    def initialize( mathetes )
      mathetes.hook_privmsg(
        :regexp => /^!time\b/
      ) do |message|
        @message = message
        if message.text =~ /^!time\b\s+(\w\w?\w?)((\+|-)\d\d?)?/
          adjustment = ($2.nil?) ? 0 : $2.strip.to_i * 3600
          answer $1, adjustment
        elsif message.text =~ /^!time\b\s*$/
          answer DEFAULT_TIMEZONE, 0
        end
      end
    end
    
    def answer( tz, adjustment )
      time = Time.at Time.now.utc + Time.zone_offset(tz) + adjustment
      @message.answer time.strftime ANSWER.gsub("%Z", tz)
    end
    
  end
end; end
