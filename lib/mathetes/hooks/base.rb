module Mathetes
  module Hooks

    class Base
      attr_reader :plugin

      def initialize( args = {}, &block )
        @plugin = args[ :plugin ] or raise "Mathetes::Hooks: Missing :plugin argument"
        @block = block
      end

      def call( *args )
        @block.call *args
      end
    end

  end
end
