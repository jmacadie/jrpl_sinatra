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

      def initialize(remember_me_repository:, token_generator:, hasher:)
        @remember_me_repository = remember_me_repository
        @token_generator = token_generator
        @hasher = hasher
      end

      def call(series_id:, token:)
        return result(:missing_credentials) unless series_id && token

        user = @remember_me_repository.user_from_series(series_id)
        return result(:unknown_series) unless user

        unless @hasher.matches?(token, user[:token])
          @remember_me_repository.delete_cookie_data(series_id)
          return result(:invalid_token, series_id:)
        end

        rotate_token(user[:user_id], series_id)
      end

      def save_new(user_id:, series_id:, token:)
        digest = @hasher.hash(token)
        @remember_me_repository.save_new_cookie(user_id, series_id, digest)
      end

      private

      def rotate_token(user_id, series_id)
        new_token = @token_generator.call
        token_digest = @hasher.hash(new_token)
        @remember_me_repository.update_token(series_id, token_digest)
        result(:success, user_id:, new_token:, series_id:)
      end

      def result(status, user_id: nil, new_token: nil, series_id: nil)
        Result.new(status:, user_id:, new_token:, series_id:)
      end
    end
  end
end
