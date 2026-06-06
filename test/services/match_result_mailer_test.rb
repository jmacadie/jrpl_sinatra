require_relative '../helpers/test_helpers'

class MatchResultMailerTest < Minitest::Test
  def test_sends_result_email_with_explicit_collaborators
    collaborators = build_collaborators
    mailer = build_mailer(collaborators)

    mailer.send_result_email(6)

    assert_equal [[:load_match, 6]], collaborators[:match].calls
    assert_equal [
      [:get_predictions_results, 6]
    ], collaborators[:predictions].calls
    assert_equal [[:scoreboard_data, 'Official']],
                 collaborators[:scoreboard].calls
    assert_rendered_result(collaborators)
    assert_email_sent(collaborators)
    assert_equal [
      [
        :run_query,
        'UPDATE emails SET results_sent = true WHERE match_id = $1::int',
        6
      ]
    ], collaborators[:query_runner].calls
  end

  def build_collaborators
    {
      match: FakeMatchRepository.new(match: match),
      predictions: FakeMatchPredictionRepository.new(
        predictions: [{ user: 'Maccas' }]
      ),
      scoreboard: FakeScoreboardService.new(
        data: { overall_table: [{ user_name: 'Maccas' }] }
      ),
      renderer: FakeRenderer.new(body: '<html>result</html>'),
      email_sender: FakeEmailSender.new,
      query_runner: FakeQueryRunner.new
    }
  end

  def build_mailer(collaborators)
    MatchResultMailer.new(
      match_repository: collaborators[:match],
      prediction_repository: collaborators[:predictions],
      scoreboard_service: collaborators[:scoreboard],
      renderer: collaborators[:renderer],
      email_sender: collaborators[:email_sender],
      query_runner: collaborators[:query_runner]
    )
  end

  def assert_rendered_result(collaborators)
    assert_equal [
      [
        :render,
        :'email/result',
        {
          match:,
          predictions: [{ user: 'Maccas' }],
          table: [{ user_name: 'Maccas' }]
        }
      ]
    ], collaborators[:renderer].calls
  end

  def assert_email_sent(collaborators)
    assert_equal [
      [
        :send_email_all,
        {
          subject: 'Results for Slovenia vs. Denmark',
          body: '<html>result</html>'
        }
      ]
    ], collaborators[:email_sender].calls
  end

  def match
    {
      home_name: 'Slovenia',
      home_tournament_role: 'Home',
      away_name: 'Denmark',
      away_tournament_role: 'Away'
    }
  end

  class FakeMatchRepository
    attr_reader :calls, :match

    def initialize(match:)
      @match = match
      @calls = []
    end

    def load_match(match_id)
      calls << [:load_match, match_id]
      @match
    end
  end

  class FakeMatchPredictionRepository
    attr_reader :calls

    def initialize(predictions:)
      @predictions = predictions
      @calls = []
    end

    def get_predictions_results(match_id)
      calls << [:get_predictions_results, match_id]
      @predictions
    end
  end

  class FakeScoreboardService
    attr_reader :calls

    def initialize(data:)
      @data = data
      @calls = []
    end

    def scoreboard_data(scoring_system)
      calls << [:scoreboard_data, scoring_system]
      @data
    end
  end

  class FakeRenderer
    attr_reader :calls

    def initialize(body:)
      @body = body
      @calls = []
    end

    def render(template, locals:)
      calls << [:render, template, locals]
      @body
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

  class FakeQueryRunner
    attr_reader :calls

    def initialize
      @calls = []
    end

    def run_query(statement, *params)
      calls << [:run_query, statement, *params]
    end
  end
end
