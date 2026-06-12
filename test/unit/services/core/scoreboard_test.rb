require "test_helpers"

class ScoreboardServiceTest < Minitest::Test
  def test_updates_official_scoring_for_predictions
    prediction_repository = FakePredictionRepository.new(
      predictions: [
        { pred_id: 10, home_score: 2, away_score: 1 },
        { pred_id: 11, home_score: 1, away_score: 1 },
        { pred_id: 12, home_score: 0, away_score: 1 }
      ]
    )
    point_repository = FakePointRepository.new
    service = Services::Core::Scoreboard.new(
      match_repository: FakeMatchRepository.new,
      prediction_repository:,
      point_repository:
    )

    service.update_scoreboard(6, 2, 1)

    assert_equal [[:predictions_for_match, 6]], prediction_repository.calls
    assert_equal [
      [:add_points, 10, 1, 1, 2],
      [:add_points, 11, 1, 0, 0],
      [:add_points, 12, 1, 0, 0]
    ], point_repository.calls
  end

  def test_can_load_result_from_match_repository_when_scores_are_omitted
    match_repository = FakeMatchRepository.new(
      match: { home_score: 1, away_score: 1 }
    )
    prediction_repository = FakePredictionRepository.new(
      predictions: [
        { pred_id: 10, home_score: 0, away_score: 0 }
      ]
    )
    point_repository = FakePointRepository.new
    service = Services::Core::Scoreboard.new(
      match_repository:,
      prediction_repository:,
      point_repository:
    )

    service.update_scoreboard(6)

    assert_equal [[:load_single_match, 1, 6]], match_repository.calls
    assert_equal [
      [:add_points, 10, 1, 1, 0]
    ], point_repository.calls
  end

  def test_ranks_scoreboard_data_from_point_repository
    point_repository = FakePointRepository.new(
      scoreboard_data: unranked_scoreboard_data
    )
    service = Services::Core::Scoreboard.new(
      match_repository: FakeMatchRepository.new,
      prediction_repository: FakePredictionRepository.new,
      point_repository:
    )

    assert_equal(
      %w(1 2),
      service.scoreboard_data('Official')[:overall_table].map do |row|
        row[:rank]
      end
    )
    assert_equal [
      [:load_scoreboard_data, 'Official']
    ], point_repository.calls
  end

  private

  def unranked_scoreboard_data
    {
      overall_table: [
        { user_name: 'Maccas', total_points: 3 },
        { user_name: 'Clare Mac', total_points: 1 }
      ],
      group_table: [],
      knockout_table: []
    }
  end

  class FakeMatchRepository
    attr_reader :calls

    def initialize(match: {})
      @match = match
      @calls = []
    end

    def load_single_match(user_id, match_id)
      calls << [:load_single_match, user_id, match_id]
      @match
    end
  end

  class FakePredictionRepository
    attr_reader :calls

    def initialize(predictions: [])
      @predictions = predictions
      @calls = []
    end

    def predictions_for_match(match_id)
      calls << [:predictions_for_match, match_id]
      @predictions
    end
  end

  class FakePointRepository
    attr_reader :calls

    def initialize(scoreboard_data: nil)
      @scoreboard_data = scoreboard_data
      @calls = []
    end

    def add_points(pred_id, scoring_system_id, result_pts, score_pts)
      calls << [:add_points, pred_id, scoring_system_id, result_pts, score_pts]
    end

    def load_scoreboard_data(scoring_system)
      calls << [:load_scoreboard_data, scoring_system]
      @scoreboard_data
    end
  end
end
