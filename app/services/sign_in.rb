module Services
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

    def initialize(user_repository:)
      @user_repository = user_repository
    end

    def call(login:, password:)
      user = @user_repository.find_sign_in_user(login.strip)
      return failure if user.nil?
      return failure unless valid_password?(user, password.strip)

      Result.new(
        success: true,
        user_id: user[:user_id],
        user_name: user[:user_name],
        email: user[:email].downcase,
        roles: user[:roles]
      )
    end

    private

    def valid_password?(user, password)
      BCrypt::Password.new(user[:pword]) == password
    end

    def failure
      Result.new(success: false)
    end
  end
end
