# frozen_string_literal: true

module Dry
  class Lifecycle
    class Exit
      attr_reader :name, :guards

      def initialize(name)
        @name = name
        @guards = []
      end

      def guard(operation)
        guards << operation
        self
      end
    end
  end
end
