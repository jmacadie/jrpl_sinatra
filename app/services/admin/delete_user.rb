module Services
  module Admin
    class DeleteUser
      Result = Struct.new(:message, :message_level, keyword_init: true)

      def initialize(user_repository:)
        @user_repository = user_repository
      end

      def call(user_id:, current_user_id:)
        parsed_user_id = user_id.to_i
        return self_delete_result if parsed_user_id == current_user_id

        user_name = @user_repository.user_name(user_id: parsed_user_id)
        return invalid_user_result(user_id) if user_name.nil?

        @user_repository.delete_user(user_id: parsed_user_id)
        Result.new(
          message: "#{user_name} is no longer with us 🕳️",
          message_level: 'warn'
        )
      end

      private

      def self_delete_result
        Result.new(
          message: "You can't delete yourself, you lemon 🍋",
          message_level: 'danger'
        )
      end

      def invalid_user_result(user_id)
        Result.new(
          message: "#{user_id} is not a valid user_id",
          message_level: 'danger'
        )
      end
    end
  end
end
