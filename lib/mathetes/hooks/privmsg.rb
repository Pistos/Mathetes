module Mathetes
  module Hooks

    class PRIVMSG < Base
      attr_reader :regexp

      def initialize( args = {}, &block )
        @regexp = args[ :regexp ]
        super( args, &block )
      end
    end

  end
end
