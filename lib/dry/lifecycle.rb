# frozen_string_literal: true

require 'dry/configurable'
require 'dry/container'
require 'dry/matcher'
require 'dry/matcher/result_matcher'

require 'dry/lifecycle/version'
require 'dry/lifecycle/errors'
require 'dry/lifecycle/definition'
require 'dry/lifecycle/persistor'

module Dry
  def self.Lifecycle(container:, **opts)
    Class.new(Dry::Lifecycle) do
      config.container = container
      config.persist = opts[:persist]
      config.persist_raises = opts[:persist_raises]
    end
  end

  class Lifecycle
    extend Dry::Configurable

    setting :container, {}
    setting :persist, nil
    setting :persist_raises, nil

    class << self
      attr_reader :definition

      def define(&block)
        @definition ||= Definition.new(container: config.container, &block)
      end
    end

    include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

    def call(object, new_state)
      result = _definition.enter(object, new_state)
      result.tee { |obj| Persistor.call(obj, self.class.config.to_h) }
    end

    def in_state?(object, state)
      _definition.state?(object, state)
    end

    def states
      _definition.states
    end

    private

    def _definition
      self.class.definition
    end
  end
end
