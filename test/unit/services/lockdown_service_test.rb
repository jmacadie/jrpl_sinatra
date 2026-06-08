require_relative '../../helpers/test_helpers'

class LockdownServiceTest < Minitest::Test
  def test_processes_matches_inside_the_lockdown_window
    collaborators = build_collaborators(
      matches: [{ match_id: 6 }]
    )
    service = build_service(collaborators)

    service.call

    assert_processed_calls(collaborators)
    assert_rendered_email(collaborators)
    assert_sent_email(collaborators)
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
      [:no_predictions_email_sent_matches],
      [:load_match, 6]
    ], collaborators[:match].calls
    assert_equal [[:get_predictions_results, 6]],
                 collaborators[:prediction].calls
    assert_equal [[:call, 6]], collaborators[:mr_men].calls
    assert_equal [[:record_predictions_sent, 6]],
                 collaborators[:emails_sent_repository].calls
    assert_equal [[:locked_down, 6]], collaborators[:lockdown_policy].calls
  end

  def assert_unprocessed(collaborators)
    assert_empty collaborators[:prediction].calls
    assert_empty collaborators[:mr_men].calls
    assert_empty collaborators[:emails_sent_repository].calls
    assert_empty collaborators[:renderer].calls
    assert_empty collaborators[:email_sender].calls
  end

  def build_collaborators(matches:, locked_down: true)
    {
      match: FakeMatchRepository.new(matches:),
      prediction: FakePredictionRepository.new,
      emails_sent_repository: FakeEmailsSentRepository.new,
      mr_men: FakeMrMenService.new,
      renderer: FakeRenderer.new,
      email_sender: FakeEmailSender.new,
      lockdown_policy: FakeLockdownPolicy.new(locked_down:)
    }
  end

  def build_service(collaborators)
    Services::Lockdown.new(
      match_repository: collaborators[:match],
      prediction_repository: collaborators[:prediction],
      emails_sent_repository: collaborators[:emails_sent_repository],
      mr_men_service: collaborators[:mr_men],
      renderer: collaborators[:renderer],
      email_sender: collaborators[:email_sender],
      lockdown_policy: collaborators[:lockdown_policy]
    )
  end

  def assert_rendered_email(collaborators)
    assert_equal [
      [
        :render,
        :'email/prediction',
        {
          match: collaborators[:match].match,
          predictions: [{ user: 'Maccas' }]
        }
      ]
    ], collaborators[:renderer].calls
  end

  def assert_sent_email(collaborators)
    assert_equal [
      [
        :send_email_all,
        {
          subject: 'Predictions for Spain vs. Croatia',
          body: '<html>predictions</html>'
        }
      ]
    ], collaborators[:email_sender].calls
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

  class FakePredictionRepository
    attr_reader :calls

    def initialize
      @calls = []
    end

    def get_predictions_results(match_id)
      calls << [:get_predictions_results, match_id]
      [{ user: 'Maccas' }]
    end
  end

  class FakeEmailsSentRepository
    attr_reader :calls

    def initialize
      @calls = []
    end

    def record_predictions_sent(match_id)
      calls << [:record_predictions_sent, match_id]
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

  class FakeRenderer
    attr_reader :calls

    def initialize
      @calls = []
    end

    def render(template, locals:)
      calls << [:render, template, locals]
      '<html>predictions</html>'
    end
  end

  class FakeEmailSender
    attr_reader :calls

    def initialize
      @calls = []
    end

    def send_email_all(subject:, body:)
      calls << [:send_email_all, { subject:, body: }]
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
