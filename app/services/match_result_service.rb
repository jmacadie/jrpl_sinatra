class MatchResultService
  Result = Struct.new(
    :success,
    :message,
    :match_id,
    :home_score,
    :away_score,
    keyword_init: true
  ) do
    def success?
      success
    end
  end

  def initialize(attributes)
    @match_id = attributes.fetch(:match_id)
    @home_score = attributes.fetch(:home_score)
    @away_score = attributes.fetch(:away_score)
    @user_id = attributes.fetch(:user_id)
    @operations = attributes.fetch(:operations)
  end

  def call
    home_score = @home_score.to_f
    away_score = @away_score.to_f
    match = @operations.load_match(@match_id)
    message = match_result_error(match, home_score, away_score)
    return failure(message, home_score, away_score) if message

    home_score = home_score.to_i
    away_score = away_score.to_i

    @operations.add_result(@match_id, home_score, away_score, @user_id)
    @operations.update_scoreboard(@match_id, home_score, away_score)
    @operations.send_result_email(@match_id)

    Result.new(
      success: true,
      match_id: @match_id,
      home_score:,
      away_score:
    )
  end

  private

  def match_result_error(match, home_score, away_score)
    if match_locked_down?(match)
      match_result_type_error(home_score, away_score)
    else
      'You cannot add or change the match result because ' \
        'this match has not yet been played.'
    end
  end

  def match_result_type_error(home_score, away_score)
    error = []
    error << 'integers' if
      not_integer?(home_score) || not_integer?(away_score)
    error << 'non-negative' if
      home_score < 0 || away_score < 0
    return nil if error.empty?
    "Match results must be #{error.join(' and ')}."
  end

  def match_locked_down?(match)
    match[:match_datetime] < Time.now + App::LOCKDOWN_BUFFER
  end

  def not_integer?(num)
    !(num.floor - num).zero?
  end

  def failure(message, home_score, away_score)
    Result.new(
      success: false,
      message:,
      match_id: @match_id,
      home_score:,
      away_score:
    )
  end
end
