module Policies
  class Lockdown
    def initialize(clock: Time, buffer: App::LOCKDOWN_BUFFER)
      @clock = clock
      @buffer = buffer
    end

    def locked_down?(match)
      match[:match_datetime] < @clock.now + @buffer
    end
  end
end
