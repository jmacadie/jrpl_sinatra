module Services
  class MatchPrediction
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

    def initialize(match_repository:, prediction_repository:, lockdown_policy:)
      @match_repository = match_repository
      @prediction_repository = prediction_repository
      @lockdown_policy = lockdown_policy
    end

    def call(match_id:, home_prediction:, away_prediction:, user_id:)
      message = prediction_error(match_id, home_prediction, away_prediction)
      if message
        return failure(message:, match_id:, home_prediction:,
                       away_prediction:)
      end

      home_prediction = home_prediction.to_i
      away_prediction = away_prediction.to_i

      @prediction_repository.add_prediction(
        user_id,
        match_id,
        home_prediction,
        away_prediction
      )

      Result.new(
        success: true,
        match_id:,
        home_prediction:,
        away_prediction:
      )
    end

    private

    def prediction_error(match_id, home_prediction, away_prediction)
      match = @match_repository.load_match(match_id)
      if @lockdown_policy.locked_down?(match)
        return 'You cannot add or change your prediction because ' \
               'this match is already locked down!'
      end
      prediction_type_error(home_prediction, away_prediction)
    end

    def prediction_type_error(home_prediction, away_prediction)
      home_prediction = home_prediction.to_f
      away_prediction = away_prediction.to_f
      error = []
      error << 'integers' if
        not_integer?(home_prediction) || not_integer?(away_prediction)
      error << 'non-negative' if
        home_prediction < 0 || away_prediction < 0
      return nil if error.empty?

      "Your predictions must be #{error.join(' and ')}."
    end

    def not_integer?(num)
      !(num.floor - num).zero?
    end

    def failure(message:, match_id:, home_prediction:, away_prediction:)
      Result.new(
        success: false,
        message:,
        match_id:,
        home_prediction:,
        away_prediction:
      )
    end
  end
end
