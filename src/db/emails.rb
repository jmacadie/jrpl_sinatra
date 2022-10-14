module DBPersEmails
  def record_predictions_email_sent(match_id)
    sql = 'UPDATE emails SET predictions_sent = true WHERE match_id = $1'
    query(sql, match_id)
  end

  def record_results_email_sent(match_id)
    sql = 'UPDATE emails SET results_sent = true WHERE match_id = $1'
    query(sql, match_id)
  end
end
