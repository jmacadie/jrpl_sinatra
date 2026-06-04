class MatchResultOperations
  def initialize(app_context:, match_repository:)
    @app = app_context
    @match_repository = match_repository
  end

  def load_match(match_id)
    @match_repository.load_single_match(1, match_id)
  end

  def add_result(match_id, home_score, away_score, user_id)
    @match_repository.add_result(match_id, home_score, away_score, user_id)
  end

  def update_scoreboard(match_id, home_score, away_score)
    @app.update_scoreboard(match_id, home_score, away_score)
  end

  def send_result_email(match_id)
    @app.send(:send_result_email, match_id)
  end
end
