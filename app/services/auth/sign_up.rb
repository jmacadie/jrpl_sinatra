module Services
  module Accounts
    class SignUp
      BOT_CHECK_MESSAGE =
        'You did not enter the magic four letters correctly. ' \
        'Either you are a bot, ' \
        'or your intelligence level is not sufficient to play here. ' \
        'Goodbye'

      Result = Struct.new(
        :success,
        :message,
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

      def call(details:)
        details = normalize_details(details)
        errors = validation_errors(details)
        return failure(errors.join(' ')) unless errors.empty?

        user = @user_repository.create_user(
          user_name: details[:user_name],
          email: details[:email],
          password: details[:password]
        )
        success(user)
      end

      private

      def normalize_details(details)
        {
          user_name: details[:user_name].strip,
          email: details[:email].strip.downcase,
          password: details[:password].strip,
          password_confirmation: details[:password_confirmation].strip,
          bot_check: (details[:bot_check] || '').strip
        }
      end

      def validation_errors(details)
        errors = []
        errors << username_error(details[:user_name])
        errors << password_error(details)
        errors << email_error(details[:email])
        errors << bot_check_error(details[:bot_check])
        errors.compact
      end

      def username_error(user_name)
        if @user_repository.username_taken?(user_name)
          'That username already exists. Please choose a different username.'
        elsif user_name.empty?
          'Username cannot be blank! Please enter a username.'
        end
      end

      def password_error(details)
        if details[:password] != details[:password_confirmation] &&
           !details[:password].empty?
          'The passwords do not match.'
        elsif details[:password].empty?
          'Password cannot be blank! Please enter a password.'
        end
      end

      def email_error(email)
        if email.empty?
          'Email cannot be blank! Please enter an email.'
        elsif email !~ URI::MailTo::EMAIL_REGEXP
          'That is not a valid email address.'
        elsif @user_repository.email_taken?(email)
          'That email address already exists.'
        end
      end

      def bot_check_error(bot_check)
        BOT_CHECK_MESSAGE unless bot_check.downcase == 'jrpl'
      end

      def success(user)
        Result.new(
          success: true,
          message: 'Your account has been created.',
          user_id: user[:user_id],
          user_name: user[:user_name],
          email: user[:email].downcase,
          roles: user[:roles]
        )
      end

      def failure(message)
        Result.new(success: false, message:)
      end
    end
  end
end
