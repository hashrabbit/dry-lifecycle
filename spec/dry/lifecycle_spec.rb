require 'spec_helper'

RSpec.describe Dry::Lifecycle do
  let(:duplicate_state) { Dry::Lifecycle::DuplicateState }
  let(:invalid_exit) { Dry::Lifecycle::InvalidExit }
  let(:invalid_state) { Dry::Lifecycle::InvalidState }

  context 'when defined with no states' do
    let(:lifecycle) {
      Class.new(Dry::Lifecycle) do
        define {}
      end.new
    }

    it 'contains no states' do
      expect(lifecycle.states).to eq({})
    end
  end

  context 'when entering a new state, from an initial state' do
    let(:lifecycle) do
      Class.new(Dry::Lifecycle) do
        define do
          state(:one) { exit(:two) }
          state(:two)
        end
      end.new
    end
    let(:object) { Struct.new(:state).new('one') }
    let(:result) { lifecycle.call(object, :two) }

    it 'returns Success, wrapping the object in the new state' do
      expect(result.value!.state).to eq('two')
    end

    it 'yields the value to #success, when called with a block' do
      result = lifecycle.call(object, :two) do |r|
        r.success { |v| v }
        r.failure {}
      end
      expect(result.state).to eq('two')
    end
  end
end
