class MatchPredictionOperations
  def initialize(match_repository:, prediction_repository:)
    @match_repository = match_repository
    @prediction_repository = prediction_repository
  end

  def load_match(user_id, match_id)
    @match_repository.load_single_match(user_id, match_id)
  end

  def add_prediction(user_id, match_id, home_prediction, away_prediction)
    @prediction_repository.add_prediction(
      user_id,
      match_id,
      home_prediction,
      away_prediction
    )
  end
end
