module DBUsers
  def load_all_users_details
    sql = select_query_all_users()
    result = run_query(sql)
    result.map do |row|
      row_to_users_details_hash(row)
    end
  end

  def load_user_details(user_id)
    sql = select_query_single_user()
    result = run_query(sql, user_id)
    return nil if result.ntuples == 0
    result.map do |row|
      row_to_users_details_hash(row)
    end.first
  end

  private

  def select_query_all_users
    <<~SQL
      SELECT users.user_id, users.user_name, users.email, string_agg(role.name, ', ') AS roles
      FROM users
      FULL OUTER JOIN user_role ON users.user_id = user_role.user_id
      FULL OUTER JOIN role ON user_role.role_id = role.role_id
      GROUP BY users.user_id, users.user_name, users.email
      ORDER BY UPPER(users.user_name);
    SQL
  end

  def select_query_single_user
    <<~SQL
      SELECT users.user_id, users.user_name, users.email, string_agg(role.name, ', ') AS roles
      FROM users
      FULL OUTER JOIN user_role ON users.user_id = user_role.user_id
      FULL OUTER JOIN role ON user_role.role_id = role.role_id
      WHERE users.user_id = $1::int
      GROUP BY users.user_id, users.user_name, users.email
    SQL
  end

  def row_to_users_details_hash(row)
    { user_id: row['user_id'].to_i,
      user_name: row['user_name'],
      email: row['email'],
      roles: row['roles'] }
  end
end
