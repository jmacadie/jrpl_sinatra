require "test_helpers"

class LockdownServiceTest < Minitest::Test
  def test_processes_matches_inside_the_lockdown_window
    collaborators = build_collaborators(
      matches: [{ match_id: 6 }]
    )
    service = build_service(collaborators)

    service.call

    assert_processed_calls(collaborators)
  end

  def test_ignores_matches_outside_the_lockdown_window
    collaborators = build_collaborators(
      matches: [{ match_id: 7 }], locked_down: false
    )
    service = build_service(collaborators)

    service.call

    assert_equal [[:no_predictions_email_sent_matches]],
                 collaborators[:match].calls
    assert_unprocessed(collaborators)
    assert_equal [[:locked_down, 7]], collaborators[:lockdown_policy].calls
  end

  private

  def assert_processed_calls(collaborators)
    assert_equal [
      [:no_predictions_email_sent_matches]
    ], collaborators[:match].calls
    assert_equal [[:call, 6]], collaborators[:mr_men].calls
    assert_equal [[:call, 6]], collaborators[:predictions_mailer].calls
    assert_equal [[:locked_down, 6]], collaborators[:lockdown_policy].calls
  end

  def assert_unprocessed(collaborators)
    assert_empty collaborators[:mr_men].calls
    assert_empty collaborators[:predictions_mailer].calls
  end

  def build_collaborators(matches:, locked_down: true)
    {
      match: FakeMatchRepository.new(matches:),
      mr_men: FakeMrMenService.new,
      predictions_mailer: FakePredictionsMailer.new,
      lockdown_policy: FakeLockdownPolicy.new(locked_down:)
    }
  end

  def build_service(collaborators)
    Services::Core::Lockdown.new(
      match_repository: collaborators[:match],
      mr_men_service: collaborators[:mr_men],
      predictions_mailer: collaborators[:predictions_mailer],
      lockdown_policy: collaborators[:lockdown_policy]
    )
  end

  class FakeMatchRepository
    attr_reader :calls, :match

    def initialize(matches:)
      @matches = matches
      @match = {
        home_name: 'Spain',
        home_tournament_role: 'Home',
        away_name: 'Croatia',
        away_tournament_role: 'Away'
      }
      @calls = []
    end

    def no_predictions_email_sent_matches
      calls << [:no_predictions_email_sent_matches]
      @matches
    end

    def load_match(match_id)
      calls << [:load_match, match_id]
      match
    end
  end

  class FakeMrMenService
    attr_reader :calls

    def initialize
      @calls = []
    end

    def call(match_id)
      calls << [:call, match_id]
    end
  end

  class FakePredictionsMailer
    attr_reader :calls

    def initialize
      @calls = []
    end

    def call(match_id)
      calls << [:call, match_id]
    end
  end

  class FakeLockdownPolicy
    attr_reader :calls

    def initialize(locked_down:)
      @calls = []
      @locked_down = locked_down
    end

    def locked_down?(match)
      calls << [:locked_down, match[:match_id]]
      @locked_down
    end
  end
end
