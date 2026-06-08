module Services
  class Lockdown
    def initialize(dependencies)
      @match_repository = dependencies.fetch(:match_repository)
      @prediction_repository = dependencies.fetch(:prediction_repository)
      @emails_sent_repository = dependencies.fetch(:emails_sent_repository)
      @mr_men_service = dependencies.fetch(:mr_men_service)
      @renderer = dependencies.fetch(:renderer)
      @email_sender = dependencies.fetch(:email_sender)
      @lockdown_policy = dependencies.fetch(:lockdown_policy)
    end

    def call
      @match_repository.no_predictions_email_sent_matches.each do |match|
        process_match(match) if @lockdown_policy.locked_down?(match)
      end
    end

    private

    def process_match(match)
      match_id = match[:match_id]
      @mr_men_service.call(match_id)
      send_email(match_id)
      @emails_sent_repository.record_predictions_sent(match_id)
    end

    def send_email(match_id)
      match = @match_repository.load_match(match_id)
      predictions =
        @prediction_repository.get_predictions_results(match_id)
      @email_sender.send_email_all(
        subject: email_subject(match),
        body: email_body(match, predictions)
      )
    end

    def email_subject(match)
      teams = Presenters::MatchTeams.new(match)
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
