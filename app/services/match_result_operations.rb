class MatchResultOperations
  def initialize(app_context)
    @app_context = app_context
  end

  def load_match(match_id)
    @app_context.send(:load_single_match, 1, match_id)
  end

  def add_result(match_id, home_score, away_score, user_id)
    @app_context.send(:add_result, match_id, home_score, away_score, user_id)
  end

  def update_scoreboard(match_id, home_score, away_score)
    @app_context.send(:update_scoreboard, match_id, home_score, away_score)
  end

  def send_result_email(match_id)
    @app_context.send(:send_result_email, match_id)
  end
end
