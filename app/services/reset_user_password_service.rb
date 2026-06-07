class ResetUserPasswordService
  DEFAULT_PASSWORD = 'jrpl'

  Result = Struct.new(:message, keyword_init: true)

  def initialize(user_repository:)
    @user_repository = user_repository
  end

  def call(user_name:)
    @user_repository.reset_password(user_name, DEFAULT_PASSWORD)
    Result.new(
      message: "The password has been reset to 'jrpl' for #{user_name}."
    )
  end
end
