require_relative '../helpers/test_helpers'

class CMSTest < Minitest::Test
  include TestIntegrationMethods
  include TestEmailMethods

  def test_result_email
    Mail::TestMailer.deliveries.clear
    assert_equal 0, Mail::TestMailer.deliveries.length

    # Clear out any predictions emails before we get started
    get '/'
    Mail::TestMailer.deliveries.clear
    assert_equal 0, Mail::TestMailer.deliveries.length

    post '/match/add_result',
         { match_id: 6, home_score: 81, away_score: 82 },
         admin_session
    assert_equal 1, Mail::TestMailer.deliveries.length

    match = get_mail_by_subject('TEST: Results for Slovenia vs. Denmark')
    refute_nil(match)

    body_text = email_body_text(match)
    assert_includes body_text, 'New result posted'
    assert_includes body_text, 'Slovenia 81 - 82 Denmark'
    assert_includes body_text, 'Details for match'
    assert_includes body_text, 'Maccas Denmark Win 82 - 81 1 2 3'
    assert_includes body_text, 'Clare Mac Denmark Win 72 - 71 1 - 1'
    assert_includes body_text, 'Sammie No prediction - - -'
    assert_includes body_text, 'Current League Table'
    assert_includes body_text, '1=3D Clare Mac 2 2 4'
    assert_includes body_text, '1=3D Maccas 2 2 4'
    assert_includes body_text, '6=3D Sammie - - -'
    Mail::TestMailer.deliveries.clear
  end

  def test_result_email_diff_resilt
    Mail::TestMailer.deliveries.clear
    assert_equal 0, Mail::TestMailer.deliveries.length

    # Clear out any predictions emails before we get started
    get '/'
    Mail::TestMailer.deliveries.clear
    assert_equal 0, Mail::TestMailer.deliveries.length

    post '/match/add_result',
         { match_id: 6, home_score: 71, away_score: 72 },
         admin_session
    assert_equal 1, Mail::TestMailer.deliveries.length

    match = get_mail_by_subject('TEST: Results for Slovenia vs. Denmark')
    refute_nil(match)

    body_text = email_body_text(match)
    assert_includes body_text, 'New result posted'
    assert_includes body_text, 'Slovenia 71 - 72 Denmark'
    assert_includes body_text, 'Details for match'
    assert_includes body_text, 'Clare Mac Denmark Win 72 - 71 1 2 3'
    assert_includes body_text, 'Maccas Denmark Win 82 - 81 1 - 1'
    assert_includes body_text, 'Sammie No prediction - - -'
    assert_includes body_text, 'Current League Table'
    assert_includes body_text, '1 Clare Mac 2 4 6'
    assert_includes body_text, '2 Maccas 2 - 2'
    assert_includes body_text, '6=3D Sammie - - -'
    Mail::TestMailer.deliveries.clear
  end

  def test_result_email_post_twice
    # Clear out any predictions emails before we get started
    get '/'
    Mail::TestMailer.deliveries.clear

    post '/match/add_result',
         { match_id: 6, home_score: 81, away_score: 82 },
         admin_session
    assert_equal 1, Mail::TestMailer.deliveries.length
    Mail::TestMailer.deliveries.clear
    assert_equal 0, Mail::TestMailer.deliveries.length
    post '/match/add_result',
         { match_id: 6, home_score: 81, away_score: 82 },
         admin_session
    assert_equal 1, Mail::TestMailer.deliveries.length

    match = get_mail_by_subject('TEST: Results for Slovenia vs. Denmark')
    refute_nil(match)

    body_text = email_body_text(match)
    assert_includes body_text, 'New result posted'
    assert_includes body_text, 'Slovenia 81 - 82 Denmark'
    assert_includes body_text, 'Details for match'
    assert_includes body_text, 'Maccas Denmark Win 82 - 81 1 2 3'
    assert_includes body_text, 'Clare Mac Denmark Win 72 - 71 1 - 1'
    assert_includes body_text, 'Sammie No prediction - - -'
    assert_includes body_text, 'Current League Table'
    assert_includes body_text, '1=3D Clare Mac 2 2 4'
    assert_includes body_text, '1=3D Maccas 2 2 4'
    assert_includes body_text, '6=3D Sammie - - -'
    Mail::TestMailer.deliveries.clear
  end
end
