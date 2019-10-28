# frozen_string_literal: true

require 'dry/configurable'
require 'dry/container'
require 'dry/matcher'
require 'dry/matcher/result_matcher'

require 'dry/lifecycle/version'
require 'dry/lifecycle/errors'
require 'dry/lifecycle/definition'

module Dry
  def self.Lifecycle(container:)
    Class.new(Dry::Lifecycle) do
      config.container = container
    end
  end

  class Lifecycle
    extend Dry::Configurable

    setting :container, {}

    class << self
      attr_reader :definition

      def define(&block)
        @definition ||= Definition.new(container: config.container, &block)
      end
    end

    include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

    def call(object, new_state)
      _definition.enter(object, new_state)
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
