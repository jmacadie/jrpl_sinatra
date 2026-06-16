module Services
  module Core
    class MrMen
      def initialize(prediction_repository:)
        @prediction_repository = prediction_repository
      end

      def call(match_id:)
        predictions = @prediction_repository.get_predictions_results(match_id:)
        scores = prediction_scores(predictions)
        add_prediction(1, match_id, mean(scores[:home]), mean(scores[:away]))
        add_prediction(2, match_id,
                       median(scores[:home]),
                       median(scores[:away]))
        add_prediction(3, match_id, mode(scores[:home]), mode(scores[:away]))
      end

      private

      def prediction_scores(predictions)
        {
          home: scores_for(predictions, :home_prediction),
          away: scores_for(predictions, :away_prediction)
        }
      end

      def scores_for(predictions, key)
        predictions.map { |prediction| prediction[key] }.compact.sort
      end

      def add_prediction(user_id, match_id, home_score, away_score)
        @prediction_repository.add_prediction(
          user_id:,
          match_id:,
          home_score:,
          away_score:
        )
      end

      def mean(array)
        return 0 if array.empty?

        (array.sum(0.0) / array.size).round
      end

      def median(array)
        return 0 if array.empty?

        index = array.size / 2
        return mean(array[index - 1, 2]) if array.size.even?

        array[index]
      end

      def mode(array)
        return 0 if array.empty?

        tallied = array.tally
        maximum = tallied.values.max
        modes = tallied.filter_map { |score, count| score if count == maximum }
        mean(modes)
      end
    end
  end
end
