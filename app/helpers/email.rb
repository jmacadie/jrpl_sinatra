require_relative '../db/users'

module Email
  include DBUsers

  def send_email_all(subject: '', body: '', plain_text: false)
    users = load_all_users_details()
    to = users.reject { |u| mr_men? u }
              .map { |u| "#{u[:user_name]} <#{u[:email]}>" }
              .join(', ')
    send_email(subject:,
               body:,
               to:,
               plain_text:)
  end

  def send_email(subject: '', body: '', to: nil, plain_text: false)
    config = App.settings.email
    env = App.settings.environment
    transport = get_transport(config, env)
    to = get_to(to, config, env)
    body = replace_urls(body, env)
    params = get_params(subject, body, to, config, plain_text)
             .merge(transport)
    Pony.mail(params)
  end

  DOMAINS = {
    'development' => 'localhost:4567',
    'test' => 'localhost',
    'staging' => 'staging.julianrimet.com',
    'production' => 'julianrimet.com'
  }

  private

  def env_to_domain(env)
    DOMAINS[env]
  end

  def replace_urls(body, env)
    domain = env_to_domain(env)
    body.gsub('{URL}', domain)
  end

  def mr_men?(user)
    return false if user[:roles].nil?
    user[:roles].include?("Mr Mean") ||
      user[:roles].include?("Mr Median") ||
      user[:roles].include?("Mr Mode")
  end

  def get_params(subject, body, to, config, plain_text)
    params = {
      to: to,
      from: config['from'],
      subject:
    }
    if plain_text
      params.merge({ body: body })
    else
      params.merge({ html_body: body })
    end
  end

  def get_transport(config, env)
    if env == 'development'
      dev_transport()
    else
      prod_transport(config)
    end
  end

  def prod_transport(config)
    {
      via: :smtp,
      # rubocop:disable Layout/HashAlignment
      via_options: {
        address:              'smtp.gmail.com',
        port:                 587,
        enable_starttls_auto: true,
        user_name:            config['gmail_username'],
        password:             config['app_password'],
        # :plain, :login, :cram_md5, no auth by default
        authentication:       :plain,
        domain:               config['app_domain']
      }
      # rubocop:enable Layout/HashAlignment
    }
  end

  def dev_transport
    {
      via: :smtp,
      via_options: {
        address: 'localhost',
        port: 1025, # 8025 is the port for seeing the webmail
        enable_starttls_auto: false
      }
    }
  end

  def get_to(to, config, env)
    return config['sub_to'] if env == 'staging'
    to || config['default_to']
  end
end
