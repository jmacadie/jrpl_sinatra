module Services
  module Accounts
    class SignIn
      Result = Struct.new(
        :success,
        :user_id,
        :user_name,
        :email,
        :roles,
        keyword_init: true
      ) do
        def success?
          success
        end
      end

      def initialize(user_repository:, hasher:)
        @user_repository = user_repository
        @hasher = hasher
      end

      def call(login:, password:)
        user = @user_repository.find_sign_in_user(login.strip)
        return failure if user.nil?
        return failure unless @hasher.matches?(password.strip, user[:pword])

        Result.new(
          success: true,
          user_id: user[:user_id],
          user_name: user[:user_name],
          email: user[:email].downcase,
          roles: user[:roles]
        )
      end

      private

      def failure
        Result.new(success: false)
      end
    end
  end
end
