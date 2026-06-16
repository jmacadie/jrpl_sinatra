module Services
  module Mailers
    class Predictions
      def initialize(match_repository:,
                     prediction_repository:,
                     emails_sent_repository:,
                     renderer:,
                     email_sender:)
        @match_repository = match_repository
        @prediction_repository = prediction_repository
        @emails_sent_repository = emails_sent_repository
        @renderer = renderer
        @email_sender = email_sender
      end

      def call(match_id:)
        match = @match_repository.load_match(match_id:)
        predictions =
          @prediction_repository.get_predictions_results(match_id:)
        @email_sender.send_email_all(
          subject: email_subject(match),
          body: email_body(match, predictions)
        )
        @emails_sent_repository.record_predictions_sent(match_id:)
      end

      private

      def email_subject(match)
        teams = Presenters::MatchTeams.new(match:)
        "Predictions for #{teams.home_name} vs. #{teams.away_name}"
      end

      def email_body(match, predictions)
        @renderer.render(
          :'email/prediction',
          locals: { match:, predictions: }
        )
      end
    end
  end
end
