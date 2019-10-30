module Dry
  class Lifecycle
    Error = Class.new(StandardError)

    class DuplicateState < Error
      def initialize(state)
        super("State :#{state} has already been defined")
      end
    end

    class InvalidExit < Error
      def initialize(state)
        super("Cannot exit to state :#{state}")
      end
    end

    class InvalidState < Error
      def initialize(state)
        super("State :#{state} has not been defined")
      end
    end
  end
end
