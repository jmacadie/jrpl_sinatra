module Email
    def send_email(subject, body, to = nil)
        config = App::settings.email
        is_prod = App::settings.production?
        params = {
            :to => get_to(to, config, is_prod),
            :subject => subject,
            :body => get_body(body, to, is_prod)
        }
        params = params.merge(get_transport(config))
        Pony.mail(params)
    end

    private def get_to(to, config, is_prod)
        if is_prod
            to.nil? ? config['default_to'] : to
        else
            config['sub_to']
        end
    end

    private def get_body(body, to, is_prod)
        if is_prod
            body
        else
            'App sending to: ' + to.to_s + '   ' + body
        end
    end

    private def get_transport(config)
        {
            :via => :smtp,
            :via_options => {
                :address              => 'smtp.gmail.com',
                :port                 => 587,
                :enable_starttls_auto => true,
                :user_name            => config['gmail_username'],
                :password             => config['app_password'],
                :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
                :domain               => config['app_domain']
            }
        }
    end
end