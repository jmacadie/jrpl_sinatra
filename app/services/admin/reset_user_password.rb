module Services
  module Admin
    class ResetUserPassword
      DEFAULT_PASSWORD = 'jrpl'

      Result = Struct.new(:message, keyword_init: true)

      def initialize(user_repository:, hasher:)
        @user_repository = user_repository
        @hasher = hasher
      end

      def call(user_name:)
        digest = @hasher.hash(DEFAULT_PASSWORD)
        @user_repository.reset_password(user_name, digest)
        Result.new(
          message: "The password has been reset to '#{DEFAULT_PASSWORD}' " \
                   "for #{user_name}."
        )
      end
    end
  end
end
