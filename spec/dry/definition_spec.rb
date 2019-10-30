require 'spec_helper'

module Dry
  class Lifecycle
    RSpec.describe Definition do
      describe '.new' do
        context 'with an empty container and no block' do
          let(:defi) { described_class.new(container: {}) {} }

          it 'contains no states' do
            expect(defi.states).to eq({})
          end
        end

        context 'with 1 state' do
          let(:defi) do
            described_class.new(container: {}) { state(:one) }
          end

          it 'contains the single state' do
            expect(defi.states.keys).to eq([:one])
          end
        end

        context 'with a duplicate state' do
          let(:defi) do
            described_class.new(container: {}) do
              state(:one)
              state(:one)
            end
          end

          it 'raises a DuplicateState error' do
            expect { defi }.to raise_error(DuplicateState)
          end
        end

        context 'with a valid state exit' do
          let(:defi) do
            described_class.new(container: {}) do
              state(:one) { exit(:one) }
            end
          end

          it 'initializes properly' do
            expect(defi.states.keys).to eq([:one])
          end
        end

        context 'with an invalid state exit' do
          let(:defi) do
            described_class.new(container: {}) do
              state(:one) { exit(:two) }
            end
          end

          it 'raises an InvalidState error' do
            expect { defi }.to raise_error(InvalidState)
          end
        end
      end

      describe '#enter(object, to) - return the object in the "to" state' do
        context 'with no container' do
          let(:defi) do
            described_class.new(container: {}) do
              state(:one) { exit(:two) }
              state(:two)
            end
          end

          context 'with valid from and exit states, with no guards' do
            let(:object) { Struct.new(:state).new(:one) }

            it 'returns Success, with the object in the new state' do
              result = defi.enter(object, :two)
              expect(result).to be_a(Dry::Monads::Success)
              expect(result.value!.state).to eq('two')
            end
          end

          context 'with an invalid from state' do
            let(:object) { Struct.new(:state).new(:foo) }

            it 'returns Failure, wrapping an InvalidState error' do
              result = defi.enter(object, :two)
              expect(result).to be_a(Dry::Monads::Failure)
              expect(result.failure).to be_a(InvalidState)
            end
          end

          context 'with an invalid exit state' do
            let(:object) { Struct.new(:state).new(:one) }

            it 'returns Failure, wrapping an InvalidExit error' do
              result = defi.enter(object, :foo)
              expect(result).to be_a(Dry::Monads::Failure)
              expect(result.failure).to be_a(InvalidExit)
            end
          end
        end

        context 'when entering a new state, with a guard' do
          let(:container) {
            Container.new.register(:guard, guard_proc)
          }
          let(:defi) do
            described_class.new(container: container) do
              state(:one) { exit(:two).guard(:guard) }
              state(:two)
            end
          end
          let(:object) { Struct.new(:state).new(:one) }

          context 'when the guard is valid and passes' do
            let(:guard_proc) { ->(_, _) { Dry::Monads::Success(:guard) } }

            it 'returns Success, with the object in the new state' do
              result = defi.enter(object, :two)
              expect(result).to be_a(Dry::Monads::Success)
              expect(result.value!.state).to eq('two')
            end
          end

          context 'when the guard is valid but fails' do
            let(:guard_proc) { ->(_, _) { Dry::Monads::Failure(:error) } }

            it 'returns Failure, containing the :error value' do
              result = defi.enter(object, :two)
              expect(result).to be_a(Dry::Monads::Failure)
            end
          end

          context 'when the specified guard is invalid' do
            let(:guard_proc) { ->(_, _) { Dry::Monads::Success(:guard) } }
            let(:defi) do
              described_class.new(container: container) do
                state(:one) { exit(:two).guard(:foo) }
                state(:two)
              end
            end

            it 'returns Failure, wrapping a Dry::Container::Error' do
              result = defi.enter(object, :two)
              expect(result).to be_a(Dry::Monads::Failure)
              expect(result.failure).to be_a(Dry::Container::Error)
            end
          end
        end
      end
    end
  end
end
