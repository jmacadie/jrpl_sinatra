module Email
  def send_email(subject, body, to = nil)
    config = App.settings.email
    is_prod = App.settings.production?
    params = {
      to: get_to(to, config, is_prod),
      subject: subject,
      body: get_body(body, to, is_prod)
    }
    puts params
    params = params.merge(get_transport(config))
    Pony.mail(params)
  end

  private

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

  def get_body(body, to, is_prod)
    if is_prod
      body
    else
      "App sending to: #{to}   \n#{body}"
    end
  end

  def get_to(to, config, is_prod)
    if is_prod
      to.nil? ? config['default_to'] : to
    else
      config['sub_to']
    end
  end
end
