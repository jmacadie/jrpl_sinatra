require_relative '../helpers/test_helpers'
require "#{App.settings.src}/helpers/email"

class CMSTest < Minitest::Test
  include Email

  def test_plain_email
    Mail::TestMailer.deliveries.clear
    assert_equal 0, Mail::TestMailer.deliveries.length
    send_email(
      subject: 'Test',
      body: 'This is a plain-text e-mail',
      plain_text: true)
    assert_equal 1, Mail::TestMailer.deliveries.length
    m = Mail::TestMailer.deliveries.first
    assert_match 'This is a plain-text e-mail', m.body.raw_source
    assert_equal 'TEST: Test', m.subject
    Mail::TestMailer.deliveries.clear
  end

  def test_html_email
    Mail::TestMailer.deliveries.clear
    assert_equal 0, Mail::TestMailer.deliveries.length
    send_email(
      subject: 'Test',
      body: 'This is an HTML e-mail',
      plain_text: false)
    assert_equal 1, Mail::TestMailer.deliveries.length
    m = Mail::TestMailer.deliveries.first
    assert_match 'This is an HTML e-mail', m.html_part.body.raw_source
    assert_equal 'TEST: Test', m.subject

    Mail::TestMailer.deliveries.clear
    assert_equal 0, Mail::TestMailer.deliveries.length
    send_email(
      subject: 'Test',
      body: '<h1>This is also an HTML e-mail</h1>')
    assert_equal 1, Mail::TestMailer.deliveries.length
    m = Mail::TestMailer.deliveries.first
    assert_match '<h1>This is also an HTML e-mail</h1>', m.html_part.body.raw_source
    Mail::TestMailer.deliveries.clear
  end

  def test_email_to
    Mail::TestMailer.deliveries.clear
    assert_equal 0, Mail::TestMailer.deliveries.length
    send_email(
      subject: 'Test',
      body: 'Mail for Joe',
      to: 'joe@bloggs.com')
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
    send_email(
      subject: 'Test',
      body: 'This is a test')
    assert_equal 1, Mail::TestMailer.deliveries.length
    m = Mail::TestMailer.deliveries.first
    assert_equal 1, m.from.length
    assert_includes config['from'], m.from[0]
    Mail::TestMailer.deliveries.clear
  end

  def test_email_default_to
    Mail::TestMailer.deliveries.clear
    config = App.settings.email
    assert_equal 0, Mail::TestMailer.deliveries.length
    send_email(
      subject: 'Test',
      body: 'This is a test')
    assert_equal 1, Mail::TestMailer.deliveries.length
    m = Mail::TestMailer.deliveries.first
    assert_equal 1, m.to.length
    assert_equal config['default_to'], m.to[0]
    Mail::TestMailer.deliveries.clear
  end
end
