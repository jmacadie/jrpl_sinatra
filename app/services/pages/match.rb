module Services
  module Pages
    class Match
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
                     user_repository:,
                     lockdown_policy:)
        @match_repository = match_repository
        @prediction_repository = prediction_repository
        @user_repository = user_repository
        @lockdown_policy = lockdown_policy
      end

      def call(match_id:, user_id:, admin:)
        match = @match_repository.load_match_with_user(user_id, match_id)
        match[:locked_down] = @lockdown_policy.locked_down?(match)

        Result.new(
          match:,
          result: !match[:home_score].nil?,
          users: users(match),
          predictions: predictions(match_id, match),
          origin: origin(match_id, match),
          broadcasters: broadcasters(admin)
        )
      end

      def predictions_payload(match_id)
        match = @match_repository.load_match(match_id)
        return nil unless @lockdown_policy.locked_down?(match)

        teams = Presenters::MatchTeams.new(match)
        {
          match: {
            home_name: teams.home_name,
            away_name: teams.away_name,
            home_score: match[:home_score],
            away_score: match[:away_score]
          },
          predictions: get_predictions(match_id)
        }
      end

      private

      def get_predictions(match_id)
        @prediction_repository.get_predictions_results(match_id)
                              .map do |prediction|
          {
            name: prediction[:user],
            home: prediction[:home_prediction],
            away: prediction[:away_prediction]
          }
        end
      end

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

      def origin?(match)
        match[:stage] != 'Group Stages' && match[:stage] != 'Round of 32'
      end
    end
  end
end
