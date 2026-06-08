module Services
  class MatchResultMailer
    def initialize(dependencies)
      @match_repository = dependencies.fetch(:match_repository)
      @prediction_repository =
        dependencies.fetch(:prediction_repository)
      @scoreboard_service = dependencies.fetch(:scoreboard_service)
      @renderer = dependencies.fetch(:renderer)
      @email_sender = dependencies.fetch(:email_sender)
      @emails_sent_repository = dependencies.fetch(:emails_sent_repository)
    end

    def send_result_email(match_id)
      match = @match_repository.load_match(match_id)
      predictions = @prediction_repository.get_predictions_results(match_id)
      table = @scoreboard_service.scoreboard_data('Official')[:overall_table]
      @email_sender.send_email_all(
        subject: result_email_subject(match),
        body: result_email_body(match, predictions, table)
      )
      record_results_email_sent(match_id)
    end

    private

    def result_email_subject(match)
      "Results for #{home_name(match)} vs. #{away_name(match)}"
    end

    def result_email_body(match, predictions, table)
      @renderer.render(:'email/result',
                       locals: { match:, predictions:, table: })
    end

    def home_name(match)
      match[:home_name] || match[:home_tournament_role]
    end

    def away_name(match)
      match[:away_name] || match[:away_tournament_role]
    end

    def record_results_email_sent(match_id)
      @emails_sent_repository.record_results_sent(match_id)
    end
  end
end
