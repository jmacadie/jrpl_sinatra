module DBLogin
  def load_user_credentials
    sql = 'SELECT user_name, pword, email FROM users'
    result = query(sql)

    result.each_with_object({}) do |tuple, hash|
      hash[tuple['user_name']] =
        { pword: tuple['pword'], email: tuple['email'] }
    end
  end

  def reset_pword(username)
    new_pword = BCrypt::Password.create('jrpl').to_s
    sql = <<~SQL
    UPDATE users
    SET pword = $1::text
    WHERE user_name = $2::text;
    SQL
    query(sql, new_pword, username)
  end

  def upload_new_user_credentials(user_details)
    hashed_pword = BCrypt::Password.create(user_details[:pword]).to_s
    sql = <<~SQL
    INSERT INTO users (user_name, email, pword)
    VALUES ($1::text, $2::text, $3::text);
    SQL
    query(sql, user_details[:user_name], user_details[:email], hashed_pword)
  end
end
