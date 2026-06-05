class MatchPageOperations
  def initialize(match_repository:, match_prediction_repository:,
                 user_repository:)
    @match_repository = match_repository
    @match_prediction_repository = match_prediction_repository
    @user_repository = user_repository
  end

  def load_match(user_id, match_id)
    @match_repository.load_single_match(user_id, match_id)
  end

  def load_users
    @user_repository.load_all_users_details
  end

  def load_predictions(match_id)
    @match_prediction_repository.get_match_predictions(match_id, 1)
  end

  def load_origin(match_id)
    @match_repository.match_origin(match_id)
  end

  def load_broadcasters
    @match_repository.broadcasters
  end
end
