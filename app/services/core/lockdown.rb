module Services
  module Core
    class Lockdown
      def initialize(match_repository:,
                     mr_men_service:,
                     predictions_mailer:,
                     lockdown_policy:)
        @match_repository = match_repository
        @mr_men_service = mr_men_service
        @predictions_mailer = predictions_mailer
        @lockdown_policy = lockdown_policy
      end

      def call
        @match_repository.no_predictions_email_sent_matches.each do |match|
          process_match(match) if @lockdown_policy.locked_down?(match:)
        end
      end

      private

      def process_match(match)
        match_id = match[:match_id]
        @mr_men_service.call(match_id:)
        @predictions_mailer.call(match_id:)
      end
    end
  end
end
