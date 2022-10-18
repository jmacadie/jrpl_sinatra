module Email
  def send_email(subject: '', body: '', to: nil, plain_text: false)
    config = App.settings.email
    env = App.settings.environment
    sub_to = !(env == 'production' || env == 'test')
    params = get_params(subject, body, to, config, sub_to, env, plain_text)
             .merge(get_transport(config))
    Pony.mail(params)
  end

  private

  # rubocop:disable Metrics/ParameterLists
  def get_params(subject, body, to, config, sub_to, env, plain_text)
    # rubocop:disable Layout/HashAlignment
    params = {
      to:      get_to(to, config, sub_to),
      from:    config['from'],
      subject: subject
    }
    if plain_text
      params.merge({ body: get_body(body, to, env) })
    else
      params.merge({ html_body: get_body(body, to, env) })
    end
    # rubocop:enable Layout/HashAlignment
  end
  # rubocop:enable Metrics/ParameterLists

  # rubocop:disable Metrics/MethodLength
  def get_transport(config)
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
  # rubocop:enable Metrics/MethodLength

  def get_body(body, to, env)
    if env == 'production'
      body
    else
      "App sending to: #{to}   \n#{body}"
    end
  end

  def get_to(to, config, sub_to)
    if sub_to
      config['sub_to']
    else
      to || config['default_to']
    end
  end
end
