class MatchResultOperations
  def initialize(match_repository:, scoreboard_service:, result_mailer:)
    @match_repository = match_repository
    @scoreboard_service = scoreboard_service
    @result_mailer = result_mailer
  end

  def load_match(match_id)
    @match_repository.load_single_match(1, match_id)
  end

  def add_result(match_id, home_score, away_score, user_id)
    @match_repository.add_result(match_id, home_score, away_score, user_id)
  end

  def update_scoreboard(match_id, home_score, away_score)
    @scoreboard_service.update_scoreboard(match_id, home_score, away_score)
  end

  def send_result_email(match_id)
    @result_mailer.send_result_email(match_id)
  end
end
