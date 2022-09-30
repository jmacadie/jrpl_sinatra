module Email
    def send_email(subject, body, to = nil)
        params = {
            :to => get_to(to),
            :subject => subject,
            :body => get_body(body, to)
        }
        params = params.merge(get_transport())
        Pony.mail(params)
    end

    private def get_to(to)
        if App::settings.production?
            to.nil? ? App::settings.email_default_to : to
        else
            App::settings.email_to_sub
        end
    end

    private def get_body(body, to)
        if App::settings.production?
            body
        else
            'App sending to: ' + to.to_s + '   ' + body
        end
    end

    private def get_transport()
        {
            :via => :smtp,
            :via_options => {
                :address              => 'smtp.gmail.com',
                :port                 => '587',
                :enable_starttls_auto => true,
                :user_name            => App::settings.email_username,
                :password             => App::settings.email_password,
                :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
                :domain               => 'julianrimet.com'
            }
        }
    end
end