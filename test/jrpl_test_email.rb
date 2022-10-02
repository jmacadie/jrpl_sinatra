module TestEmail

  require_relative '../src/helpers/email'
  include Email

  def test_email
    Mail::TestMailer.deliveries.clear
    assert_equal 0, Mail::TestMailer.deliveries.length
    send_email('Test', 'This is a test')
    assert_equal 1, Mail::TestMailer.deliveries.length
    m = Mail::TestMailer.deliveries.first
    assert_match 'This is a test', m.body.raw_source
    assert_equal 'TEST: Test', m.subject
    Mail::TestMailer.deliveries.clear
  end

  def test_email_to
    Mail::TestMailer.deliveries.clear
    assert_equal 0, Mail::TestMailer.deliveries.length
    send_email('Test', 'This is a test', 'joe@bloggs.com')
    assert_equal 1, Mail::TestMailer.deliveries.length
    m = Mail::TestMailer.deliveries.first
    assert_equal 1, m.to.length
    assert_equal 'joe@bloggs.com', m.to[0]
    Mail::TestMailer.deliveries.clear
  end

  def test_email_from
    Mail::TestMailer.deliveries.clear
    config = App.settings.email
    assert_equal 0, Mail::TestMailer.deliveries.length
    send_email('Test', 'This is a test')
    assert_equal 1, Mail::TestMailer.deliveries.length
    m = Mail::TestMailer.deliveries.first
    assert_equal 1, m.from.length
    assert_equal config['from'], m.from[0]
    Mail::TestMailer.deliveries.clear
  end

  def test_email_default_to
    Mail::TestMailer.deliveries.clear
    config = App.settings.email
    assert_equal 0, Mail::TestMailer.deliveries.length
    send_email('Test', 'This is a test')
    assert_equal 1, Mail::TestMailer.deliveries.length
    m = Mail::TestMailer.deliveries.first
    assert_equal 1, m.to.length
    assert_equal config['default_to'], m.to[0]
    Mail::TestMailer.deliveries.clear
  end
end
