# frozen_string_literal: true

require 'dry/lifecycle/exit'

module Dry
  class Lifecycle
    class State
      attr_reader :name, :exits, :states

      def initialize(name:, &block)
        @name = name.to_sym
        @exits = {}
        @states = []
        @block = block
      end

      def process_exits(states)
        @states = states
        instance_eval(&@block) if @block
        self
      end

      def exit(state)
        raise InvalidState, state unless states.include?(state)

        exits[state] = Exit.new(state)
      end

      def exit?(state)
        exits.key?(state)
      end

      def guards_for(exit)
        raise InvalidExit, exit unless exit?(exit)

        exits[exit].guards
      end
    end
  end
end
