require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods
  include TestEmailMethods

  def test_lockdown_emails
    Mail::TestMailer.deliveries.clear
    assert_equal 0, Mail::TestMailer.deliveries.length

    get '/'
    assert_operator 8, :<=, Mail::TestMailer.deliveries.length

    match = get_mail_by_subject('TEST: Predictions for Spain vs. Croatia')
    body_text = email_body_text(match)
    assert_includes body_text, 'Sammie Spain Win 1 - 0'
    assert_includes body_text, 'Mr. Mode Spain Win 1 - 0'
    assert_includes body_text, 'Uwe Draw 2 - 2'
    assert_includes body_text, 'Mr. Mean Croatia Win 4 - 2'
    assert_includes body_text, 'Binary Boy Croatia Win 20 - 3'
    Mail::TestMailer.deliveries.clear
  end
end
