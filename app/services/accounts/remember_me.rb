module Services
  module Accounts
    class RememberMe
      Result = Struct.new(
        :status,
        :user_id,
        :new_token,
        :series_id,
        keyword_init: true
      ) do
        def success?
          status == :success
        end

        def invalid_token?
          status == :invalid_token
        end
      end

      def initialize(cookie_repository:, token_generator:)
        @cookie_repository = cookie_repository
        @token_generator = token_generator
      end

      def call(series_id:, token:)
        return result(:missing_credentials) unless series_id && token

        user = @cookie_repository.user_from_series(series_id)
        return result(:unknown_series) unless user

        unless BCrypt::Password.new(user[:token]) == token
          @cookie_repository.delete_cookie_data(series_id)
          return result(:invalid_token, series_id:)
        end

        rotate_token(user[:user_id], series_id)
      end

      private

      def rotate_token(user_id, series_id)
        new_token = @token_generator.call
        @cookie_repository.update_token(series_id, new_token)
        result(:success, user_id:, new_token:, series_id:)
      end

      def result(status, user_id: nil, new_token: nil, series_id: nil)
        Result.new(status:, user_id:, new_token:, series_id:)
      end
    end
  end
end
