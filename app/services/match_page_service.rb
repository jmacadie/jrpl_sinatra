class MatchPageService
  Result = Struct.new(
    :match,
    :result,
    :users,
    :predictions,
    :origin,
    :broadcasters,
    keyword_init: true
  )

  def initialize(match_repository:,
                 prediction_repository:,
                 user_repository:)
    @match_repository = match_repository
    @prediction_repository = prediction_repository
    @user_repository = user_repository
  end

  def call(match_id:, user_id:, admin:)
    match = @match_repository.load_match_with_user(user_id, match_id)
    match[:locked_down] = match_locked_down?(match)

    Result.new(
      match:,
      result: !match[:home_score].nil?,
      users: users(match),
      predictions: predictions(match_id, match),
      origin: origin(match_id, match),
      broadcasters: broadcasters(admin)
    )
  end

  private

  def users(match)
    return nil unless match[:locked_down]

    @user_repository.load_all_users_details
  end

  def predictions(match_id, match)
    return nil unless match[:locked_down]

    @prediction_repository.get_predictions_results(match_id)
  end

  def origin(match_id, match)
    return nil unless origin?(match)

    @match_repository.origin(match_id)
  end

  def broadcasters(admin)
    return nil unless admin

    @match_repository.broadcasters
  end

  def match_locked_down?(match)
    match[:match_datetime] < Time.now + App::LOCKDOWN_BUFFER
  end

  def origin?(match)
    match[:stage] != 'Group Stages' && match[:stage] != 'Round of 32'
  end
end
