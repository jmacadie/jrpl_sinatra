class MatchPredictionService
  Result = Struct.new(
    :success,
    :message,
    :match_id,
    :home_prediction,
    :away_prediction,
    keyword_init: true
  ) do
    def success?
      success
    end
  end

  def initialize(attributes)
    @match_id = attributes.fetch(:match_id)
    @home_prediction = attributes.fetch(:home_prediction)
    @away_prediction = attributes.fetch(:away_prediction)
    @user_id = attributes.fetch(:user_id)
    @operations = attributes.fetch(:operations)
  end

  def call
    home_prediction = @home_prediction.to_f
    away_prediction = @away_prediction.to_f
    match = @operations.load_match(@user_id, @match_id)
    message = prediction_error(match, home_prediction, away_prediction)
    return failure(message) if message

    home_prediction = home_prediction.to_i
    away_prediction = away_prediction.to_i

    @operations.add_prediction(
      @user_id,
      @match_id,
      home_prediction,
      away_prediction
    )

    Result.new(
      success: true,
      match_id: @match_id,
      home_prediction:,
      away_prediction:
    )
  end

  private

  def prediction_error(match, home_prediction, away_prediction)
    if match_locked_down?(match)
      'You cannot add or change your prediction because ' \
        'this match is already locked down!'
    else
      prediction_type_error(home_prediction, away_prediction)
    end
  end

  def prediction_type_error(home_prediction, away_prediction)
    error = []
    error << 'integers' if
      not_integer?(home_prediction) || not_integer?(away_prediction)
    error << 'non-negative' if
      home_prediction < 0 || away_prediction < 0
    return nil if error.empty?

    "Your predictions must be #{error.join(' and ')}."
  end

  def match_locked_down?(match)
    match[:match_datetime] < Time.now + App::LOCKDOWN_BUFFER
  end

  def not_integer?(num)
    !(num.floor - num).zero?
  end

  def failure(message)
    Result.new(
      success: false,
      message:,
      match_id: @match_id,
      home_prediction: @home_prediction,
      away_prediction: @away_prediction
    )
  end
end
