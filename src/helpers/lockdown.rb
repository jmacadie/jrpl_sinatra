module Lockdown
  def locked_down?(match)
    match[:match_datetime] < Time.now + App::LOCKDOWN_BUFFER
  end

  def check_lockdown
    matches = @storage.lockdown_matches()
    matches.each { |m| check_one_match(m) }
  end

  private

  def check_one_match(match)
    return unless locked_down?(match)
    calc_mr_men(match[:match_id])
    send_lockdown_email(match[:match_id])
    @storage.record_predictions_email_sent(match[:match_id])
  end

  def send_lockdown_email(match_id)
    match = @storage.load_single_match(1, match_id)
    predictions = @storage.get_match_predictions(match_id)
    subject = email_subject(match)
    body = lockdowm_email_body(match, predictions)
    send_email(
      subject: subject,
      body: body
    )
  end

  def email_subject(match)
    "Predictions for #{home_name(match)} vs. #{away_name(match)}"
  end

  def lockdowm_email_body(match, predictions)
    erb :'email/prediction',
        layout: false,
        locals: { match: match, predictions: predictions }
  end
end
