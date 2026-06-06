class EditUserService
  Result = Struct.new(
    :success,
    :message,
    :user_name,
    :email,
    keyword_init: true
  ) do
    def success?
      success
    end
  end

  def initialize(user_repository:)
    @user_repository = user_repository
  end

  def call(user_id:, current_password:, details:)
    current_password = current_password.strip
    details = normalize_details(details)
    current = @user_repository.load_user_credentials(user_id)
    errors = validation_errors(
      user_id:,
      current:,
      current_password:,
      details:
    )
    return failure(errors.join(' ')) unless errors.empty?

    changes = changed_details(current, details)
    apply_changes(user_id, details, changes)
    success(details, changes)
  end

  private

  def normalize_details(details)
    {
      user_name: details[:user_name].strip,
      email: details[:email].strip.downcase,
      password: details[:password].strip,
      password_confirmation: details[:password_confirmation].strip
    }
  end

  def validation_errors(user_id:, current:, current_password:, details:)
    errors = []
    errors << username_error(user_id, current, details[:user_name])
    errors << password_error(details)
    errors << email_error(user_id, current, details[:email])
    errors << credentials_error(current, current_password)
    errors << no_change_error(current, current_password, details)
    errors.compact
  end

  def username_error(user_id, current, user_name)
    if user_name.empty?
      'Username cannot be blank! Please enter a username.'
    elsif user_name != current[:user_name] &&
          @user_repository.username_exists?(user_name, except_user_id: user_id)
      'That username already exists. Please choose a different username.'
    end
  end

  def password_error(details)
    return unless details[:password] != details[:password_confirmation] &&
                  !details[:password].empty?

    'The passwords do not match.'
  end

  def email_error(user_id, current, email)
    if email.empty?
      'Email cannot be blank! Please enter an email.'
    elsif email !~ URI::MailTo::EMAIL_REGEXP
      'That is not a valid email address.'
    elsif email != current[:email].downcase &&
          @user_repository.email_exists?(email, except_user_id: user_id)
      'That email address already exists.'
    end
  end

  def credentials_error(current, current_password)
    password = BCrypt::Password.new(current[:pword])
    return if password == current_password

    'That is not the correct current password. Try again!'
  end

  def no_change_error(current, current_password, details)
    return unless current[:user_name] == details[:user_name] &&
                  unchanged_password?(current_password, details[:password]) &&
                  current[:email].downcase == details[:email]

    'You have not changed any of your details.'
  end

  def unchanged_password?(current_password, new_password)
    new_password.empty? || current_password == new_password
  end

  def changed_details(current, details)
    changes = []
    changes << 'username' if current[:user_name] != details[:user_name]
    changes << 'password' unless details[:password].empty?
    changes << 'email' if current[:email].downcase != details[:email]
    changes
  end

  def apply_changes(user_id, details, changes)
    @user_repository.change_username(user_id, details[:user_name]) if
      changes.include?('username')
    @user_repository.change_password(user_id, details[:password]) if
      changes.include?('password')
    @user_repository.change_email(user_id, details[:email]) if
      changes.include?('email')
  end

  def success(details, changes)
    Result.new(
      success: true,
      message: "The following have been updated: #{changes.join(', ')}.",
      user_name: details[:user_name],
      email: details[:email]
    )
  end

  def failure(message)
    Result.new(success: false, message:)
  end
end
