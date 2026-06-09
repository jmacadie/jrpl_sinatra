require "test_helpers"

class LockdownPolicyTest < Minitest::Test
  def test_match_before_lockdown
    clock, policy = build_policy('2026-06-08 18:43')
    match_datetime = Time.parse('2026-06-08 19:13')
    match = { match_datetime: }
    locked_down = policy.locked_down?(match)
    assert !locked_down
    assert_equal [[:now]], clock.calls
  end

  def test_match_after_lockdown
    clock, policy = build_policy('2026-06-08 18:43')
    match_datetime = Time.parse('2026-06-08 19:12')
    match = { match_datetime: }
    locked_down = policy.locked_down?(match)
    assert locked_down
    assert_equal [[:now]], clock.calls
  end

  private

  def build_policy(time)
    clock = FakeClock.new(time:)
    policy = Policies::Lockdown.new(clock:, buffer: App::LOCKDOWN_BUFFER)
    return clock, policy
  end

  class FakeClock
    attr_reader :calls

    def initialize(time:)
      @calls = []
      @time = Time.parse(time)
    end

    def now
      calls << [:now]
      @time
    end
  end
end
