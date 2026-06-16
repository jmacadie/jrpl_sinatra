module Services
  module Mailers
    class Result
      def initialize(dependencies)
        @match_repository = dependencies.fetch(:match_repository)
        @prediction_repository =
          dependencies.fetch(:prediction_repository)
        @scoreboard_service = dependencies.fetch(:scoreboard_service)
        @renderer = dependencies.fetch(:renderer)
        @email_sender = dependencies.fetch(:email_sender)
        @emails_sent_repository = dependencies.fetch(:emails_sent_repository)
      end

      def call(match_id:)
        match = @match_repository.load_match(match_id:)
        predictions = @prediction_repository.get_predictions_results(match_id:)
        tables = @scoreboard_service.data(scoring_system: 'Official')
        table = tables[:overall_table]
        @email_sender.send_email_all(
          subject: result_email_subject(match),
          body: result_email_body(match, predictions, table)
        )
        record_results_email_sent(match_id)
      end

      private

      def result_email_subject(match)
        teams = Presenters::MatchTeams.new(match:)
        "Results for #{teams.home_name} vs. #{teams.away_name}"
      end

      def result_email_body(match, predictions, table)
        @renderer.render(:'email/result',
                         locals: { match:, predictions:, table: })
      end

      def record_results_email_sent(match_id)
        @emails_sent_repository.record_results_sent(match_id:)
      end
    end
  end
end
