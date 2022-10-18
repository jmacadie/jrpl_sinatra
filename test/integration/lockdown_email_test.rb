require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods

  def test_lockdown_emails
    Mail::TestMailer.deliveries.clear
    assert_equal 0, Mail::TestMailer.deliveries.length

    get '/'
    # 8 before the WC kicks off but will increase as actual match dates pass
    dels = Mail::TestMailer.deliveries
    assert_operator 8, :<=, dels.length

    match = dels.filter { |m| subject(m) == 'TEST: Predictions for Qatar vs. Ecuador' }.first
    body_text = html_to_text(body(match))
    assert_includes body_text, 'Sammie Qatar Win 1 - 0'
    assert_includes body_text, 'Mr. Mode Qatar Win 1 - 0'
    assert_includes body_text, 'Uwe Draw 2 - 2'
    assert_includes body_text, 'Mr. Mean Ecuador Win 4 - 2'
    assert_includes body_text, 'Binary Boy Ecuador Win 20 - 3'
  end

  private

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
end
