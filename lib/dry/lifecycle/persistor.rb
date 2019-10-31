# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Dry
  class Lifecycle
    class Persistor
      include Dry::Monads[:result, :try]
      include Dry::Monads::Do.for(:call)

      attr_reader :container, :persist, :catchable

      def self.call(object, **opts)
        new(opts).call(object)
      end

      def initialize(container:, persist:, persist_raises:, **)
        @container = container
        @persist = persist
        @catchable = persist_raises || NoopError
      end

      def call(object)
        return Success(false) if container.keys.empty? || persist.nil?

        func = yield Try(Dry::Container::Error) { container[persist] }.to_result
        Try(catchable) { func.call(object) }.to_result
      end
    end
  end
end
