require 'spec_helper'

module Dry
  class Lifecycle
    RSpec.describe Persistor do
      describe '.call' do
        let(:object) { :object }
        let(:result) { Persistor.call(object, opts) }

        context 'with an empty container' do
          let(:container) { {} }
          let(:opts) {
            { container: container, persist: nil, persist_raises: nil }
          }

          it 'returns Success(false)' do
            expect(result).to be_a(Dry::Monads::Success)
            expect(result.value!).to eq(false)
          end
        end

        context 'with a nil :persist option' do
          let(:container) { Container.new.register(:one, 1) }
          let(:opts) {
            { container: container, persist: nil, persist_raises: nil }
          }

          it 'returns Success(false)' do
            expect(result).to be_a(Dry::Monads::Success)
            expect(result.value!).to eq(false)
          end
        end

        context 'with a valid :persist option' do
          let(:container) { Container.new.register(:persist, persist) }
          let(:persist) { double(:persist, call: :saved) }

          context 'when the :persist succeeds' do
            let(:opts) {
              { container: container, persist: 'persist', persist_raises: nil }
            }

            it 'returns Success, wrapping the persist fuction return' do
              expect(result).to be_a(Dry::Monads::Success)
              expect(result.value!).to eq(:saved)
            end
          end

          context 'when the :persist fails' do
            let(:error) { Class.new(StandardError) }
            let(:opts) {
              {
                container: container, persist: 'persist',
                persist_raises: error
              }
            }

            before { allow(persist).to receive(:call).and_raise(error.new) }

            it 'returns Failure, wrapping the :persist_raises exception' do
              expect(result).to be_a(Dry::Monads::Failure)
              expect(result.failure).to be_a(error)
            end
          end
        end

        context 'with an invalid :persist option' do
          let(:container) { Container.new.register(:one, 1) }
          let(:opts) {
            { container: container, persist: 'invalid', persist_raises: nil }
          }

          it 'returns Failure, wrapping a Dry::Container::Error' do
            expect(result).to be_a(Dry::Monads::Failure)
            expect(result.failure).to be_a(Dry::Container::Error)
          end
        end
      end
    end
  end
end
