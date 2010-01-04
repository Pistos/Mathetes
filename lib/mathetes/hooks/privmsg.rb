module Mathetes
  module Hooks

    class PRIVMSG < Base
      attr_reader :regexp

      def initialize( args = {}, &block )
        @regexp = args[ :regexp ] or raise "Mathetes::Hooks::PRIVMSG: Missing :regexp argument"
        super( args, &block )
      end
    end

  end
end
