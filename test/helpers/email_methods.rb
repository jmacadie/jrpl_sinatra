module TestEmailMethods
  def subject(mail)
    mail.header
        .fields
        .filter { |f| f.name == 'Subject' }
        .first
        .value
  end

  def body(mail)
    mail.html_part.body.raw_source
  end

  def email_body_text(mail)
    html_to_text(body(mail))
  end

  def get_mail_by_subject(txt)
    deliveries = Mail::TestMailer.deliveries
    deliveries.filter { |mail| subject(mail) == txt }.first
  end
end
