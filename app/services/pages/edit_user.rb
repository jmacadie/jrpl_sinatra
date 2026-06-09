module Services
  module Pages
    class EditUser
      Result = Struct.new(:user, keyword_init: true)

      def initialize(user_repository:)
        @user_repository = user_repository
      end

      def call(user_id:)
        Result.new(user: @user_repository.load_user_details(user_id))
      end
    end
  end
end
