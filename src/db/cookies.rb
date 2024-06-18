module DBCookies
  def delete_cookie_data(series_id, token)
    return if series_id.nil? || token.nil?
    sql = <<-SQL
    DELETE FROM remember_me
    WHERE series_id = $1::text AND token = $2::text;
    SQL
    query(sql, series_id, token)
  end

  def save_cookie_data(user_id, series_id_value, token_value)
    sql = <<~SQL
    INSERT INTO remember_me
    VALUES ($1::int, $2::text, $3::text, $4::timestamp);
    SQL
    query(sql, user_id, series_id_value, token_value, Time.now)
  end

  def save_new_token(user_id, series_id_value, token_value)
    sql = <<~SQL
    UPDATE remember_me
    SET token = $1::text, date_added = $2::timestamp
    WHERE user_id = $3::int AND series_id = $4::text;
    SQL
    query(sql, token_value, Time.now, user_id, series_id_value)
  end

  def series_id_list
    sql = 'SELECT series_id FROM remember_me;'
    result = query(sql)
    return [] if result.ntuples == 0
    result.map { |tuple| tuple['series_id'] }
  end

  def user_id_from_cookies(series_id, token)
    sql = <<~SQL
    SELECT user_id
    FROM remember_me
    WHERE series_id = $1::text AND token = $2::text;
    SQL
    result = query(sql, series_id, token)
    return nil if result.ntuples == 0
    result.first['user_id'].to_i
  end
end
