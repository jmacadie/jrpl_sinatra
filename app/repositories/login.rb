module DBLogin
  def reset_pword(username)
    new_pword = BCrypt::Password.create('jrpl').to_s
    sql = <<~SQL
    UPDATE users
    SET pword = $1::text
    WHERE user_name = $2::text;
    SQL
    run_query(sql, new_pword, username)
  end
end
