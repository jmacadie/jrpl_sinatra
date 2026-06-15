module Services
  module Mailers
    class EmailSender
      DOMAINS = {
        'development' => 'localhost:4567',
        'test' => 'localhost',
        'staging' => 'staging.julianrimet.com',
        'production' => 'julianrimet.com'
      }.freeze

      def initialize(config:, environment:, user_repository:)
        @config = config
        @environment = environment.to_s
        @user_repository = user_repository
      end

      def send_email_all(subject: '', body: '', plain_text: false)
        users = @user_repository.load_all_users_details
        to = users.reject { |user| mr_men?(user) }
                  .map { |user| user_address(user) }
                  .join(', ')
        send_email(subject:, body:, to:, plain_text:)
      end

      def send_email(subject: '', body: '', to: nil, plain_text: false)
        return if @environment == 'staging'
        transport = transport_options
        to = get_to(to)
        body = replace_urls(body)
        params = get_params(subject, body, to, plain_text).merge(transport)
        Pony.mail(params)
      end

      private

      def user_address(user)
        "#{user[:user_name]} <#{user[:email]}>"
      end

      def replace_urls(body)
        body.gsub('{URL}', DOMAINS[@environment])
      end

      def mr_men?(user)
        return false if user[:roles].nil?
        user[:roles].include?("Mr Mean") ||
          user[:roles].include?("Mr Median") ||
          user[:roles].include?("Mr Mode")
      end

      def get_params(subject, body, to, plain_text)
        params = {
          to:,
          from: @config['from'],
          subject:
        }
        if plain_text
          params.merge({ body: })
        else
          params.merge({ html_body: body })
        end
      end

      def transport_options
        if @environment == 'development'
          dev_transport
        else
          prod_transport
        end
      end

      def prod_transport
        {
          via: :smtp,
          # rubocop:disable Layout/HashAlignment
          via_options: {
            address:              'smtp.gmail.com',
            port:                 587,
            enable_starttls_auto: true,
            user_name:            @config['gmail_username'],
            password:             @config['app_password'],
            authentication:       :plain,
            domain:               @config['app_domain']
          }
          # rubocop:enable Layout/HashAlignment
        }
      end

      def dev_transport
        {
          via: :smtp,
          via_options: {
            address: 'localhost',
            port: 1025,
            enable_starttls_auto: false
          }
        }
      end

      def get_to(to)
        return @config['sub_to'] if @environment == 'staging'
        to || @config['default_to']
      end
    end
  end
end
