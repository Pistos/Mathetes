module Mathetes
  module Hooks

    class Base
      attr_reader :plugin

      def initialize( args = {}, &block )
        @plugin = eval( "self", block.binding )
        @block = block
      end

      def call( *args )
        @block.call *args
      end
    end

  end
end
