module Services
  module Admin
    class Result
      Result = Struct.new(
        :success,
        :message,
        :home_score,
        :away_score,
        keyword_init: true
      ) do
        def success?
          success
        end
      end

      def initialize(match_repository:,
                     scoreboard_service:,
                     result_mailer:,
                     lockdown_policy:)
        @match_repository = match_repository
        @scoreboard_service = scoreboard_service
        @result_mailer = result_mailer
        @lockdown_policy = lockdown_policy
      end

      def call(match_id:, home_score:, away_score:, user_id:)
        home_score = home_score.to_f
        away_score = away_score.to_f
        match = @match_repository.load_match(match_id:)
        message = match_result_error(match, home_score, away_score)
        return failure(message, home_score, away_score) if message

        home_score = home_score.to_i
        away_score = away_score.to_i

        @match_repository.add_result(match_id:,
                                     home_score:,
                                     away_score:,
                                     user_id:)
        @scoreboard_service.update(match_id:, home_score:, away_score:)
        @result_mailer.call(match_id:)

        Result.new(
          success: true,
          home_score:,
          away_score:
        )
      end

      private

      def match_result_error(match, home_score, away_score)
        if !@lockdown_policy.locked_down?(match:)
          return 'You cannot add or change the match result because ' \
                 'this match has not yet been played.'
        end
        match_result_type_error(home_score, away_score)
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

      def not_integer?(num)
        !(num.floor - num).zero?
      end

      def failure(message, home_score, away_score)
        Result.new(
          success: false,
          message:,
          home_score:,
          away_score:
        )
      end
    end
  end
end
