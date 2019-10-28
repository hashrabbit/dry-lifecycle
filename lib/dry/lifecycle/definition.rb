# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

require 'dry/lifecycle/state'

module Dry
  class Lifecycle
    class Definition
      include Dry::Monads[:result, :list, :try]
      include Dry::Monads::Do.for(:enter)

      attr_reader :states, :container

      def initialize(container:, &block)
        @container = container
        @states = {}
        build_states(block)
        process_states
      end

      def state(name, &block)
        sym = name.to_sym
        raise DuplicateState, sym if states.key?(sym)

        states[sym] = State.new(name: sym, &block)
      end

      def enter(object, to)
        from = yield validate_starting(object.state.to_sym)
        state = states[from]
        exit = yield validate_exit(state, to.to_sym)
        yield pass_guards(state, exit, object)
        enter_state(object, exit)
      end

      private

      def build_states(block)
        instance_eval(&block) if block
      end

      def process_states
        names = states.keys
        states.values.each { |s| s.process_exits(names) }
      end

      def validate_starting(name)
        states.key?(name) ? Success(name) : Failure(InvalidState.new(name))
      end

      def validate_exit(state, name)
        state.exit?(name) ? Success(name) : Failure(InvalidExit.new(name))
      end

      def pass_guards(state, exit, object)
        Try(InvalidExit, Dry::Container::Error) do
          guards = state.guards_for(exit).map { |g| container[g] }
          List::Result[*guards].traverse { |g| g.call(object, exit) }
        end.flatten.to_result
      end

      def enter_state(object, exit)
        Success(object.tap { |o| o.state = exit.to_s })
      end
    end
  end
end
