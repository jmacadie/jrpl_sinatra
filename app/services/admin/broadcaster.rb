module Services
  module Admin
    class Broadcaster
      Result = Struct.new(
        :success,
        :message,
        :status,
        :match_id,
        :broadcaster_id,
        keyword_init: true
      ) do
        def success?
          success
        end
      end

      def initialize(match_repository:)
        @match_repository = match_repository
      end

      def call(match_id:, broadcaster_id:)
        @match_repository.change_broadcaster(match_id, broadcaster_id)

        Result.new(
          success: true,
          message: 'Broadcaster changed',
          status: 'success',
          match_id:,
          broadcaster_id:
        )
      end
    end
  end
end
