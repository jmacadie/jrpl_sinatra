module Repositories
  class User
    def initialize(query_runner:)
      @query_runner = query_runner
    end

    def load_all_users_details
      result = @query_runner.run_query(select_query_all_users)
      result.map do |row|
        row_to_users_details_hash(row)
      end
    end

    def load_user_details(user_id:)
      result = @query_runner.run_query(select_query_single_user, user_id)
      result.map { |row| row_to_users_details_hash(row) }.first
    end

    def load_user_credentials(user_id:)
      sql = 'SELECT user_name, email, pword FROM users WHERE user_id = $1::int;'
      row = @query_runner.run_query(sql, user_id).first
      {
        user_name: row['user_name'],
        email: row['email'],
        pword: row['pword']
      }
    end

    def username_exists?(user_name:, except_user_id:)
      sql = <<~SQL
        SELECT EXISTS (
          SELECT 1 FROM users
          WHERE user_name = $1::text AND user_id <> $2::int
        ) AS exists;
      SQL
      @query_runner.run_query(sql, user_name, except_user_id)
                   .first['exists'] == 't'
    end

    def email_exists?(email:, except_user_id:)
      sql = <<~SQL
        SELECT EXISTS (
          SELECT 1 FROM users
          WHERE lower(email) = lower($1::text) AND user_id <> $2::int
        ) AS exists;
      SQL
      @query_runner.run_query(sql, email, except_user_id)
                   .first['exists'] == 't'
    end

    def change_username(user_id:, user_name:)
      sql = 'UPDATE users SET user_name = $1::text WHERE user_id = $2::int;'
      @query_runner.run_query(sql, user_name, user_id)
    end

    def change_password(user_id:, password_digest:)
      sql = 'UPDATE users SET pword = $1::text WHERE user_id = $2::int;'
      @query_runner.run_query(sql, password_digest, user_id)
    end

    def change_email(user_id:, email:)
      sql = 'UPDATE users SET email = $1::text WHERE user_id = $2::int;'
      @query_runner.run_query(sql, email, user_id)
    end

    def find_sign_in_user(login:)
      result = @query_runner.run_query(sign_in_user_query, login)
      return nil if result.ntuples.zero?

      row = result.first
      {
        user_id: row['user_id'].to_i,
        user_name: row['user_name'],
        email: row['email'],
        pword: row['pword'],
        roles: row['roles']
      }
    end

    def username_taken?(user_name:)
      sql = <<~SQL
        SELECT EXISTS (
          SELECT 1 FROM users WHERE user_name = $1::text
        ) AS exists;
      SQL
      @query_runner.run_query(sql, user_name).first['exists'] == 't'
    end

    def email_taken?(email:)
      sql = <<~SQL
        SELECT EXISTS (
          SELECT 1 FROM users WHERE lower(email) = lower($1::text)
        ) AS exists;
      SQL
      @query_runner.run_query(sql, email).first['exists'] == 't'
    end

    def create_user(user_name:, email:, password_digest:)
      sql = <<~SQL
        INSERT INTO users (user_name, email, pword)
        VALUES ($1::text, $2::text, $3::text)
        RETURNING user_id, user_name, email;
      SQL
      row = @query_runner.run_query(
        sql,
        user_name,
        email,
        password_digest
      ).first
      {
        user_id: row['user_id'].to_i,
        user_name: row['user_name'],
        email: row['email'],
        roles: nil
      }
    end

    def reset_password(user_name:, digest:)
      sql = <<~SQL
        UPDATE users
        SET pword = $1::text
        WHERE user_name = $2::text;
      SQL
      @query_runner.run_query(sql, digest, user_name)
    end

    def user_name(user_id:)
      sql = 'SELECT user_name FROM users WHERE user_id = $1::int;'
      result = @query_runner.run_query(sql, user_id)
      return nil if result.ntuples.zero?

      result.first['user_name']
    end

    def delete_user(user_id:)
      sql = 'DELETE FROM users WHERE user_id = $1::int;'
      @query_runner.run_query(sql, user_id)
    end

    def admin?(user_id:)
      sql = <<~SQL
        SELECT * FROM user_role
        WHERE user_id = $1::int AND role_id = $2::int;
      SQL
      result = @query_runner.run_query(sql, user_id, admin_role_id)
      !result.ntuples.zero?
    end

    def grant_admin(user_id:)
      sql = 'INSERT INTO user_role VALUES ($1::int, $2::int);'
      @query_runner.run_query(sql, user_id, admin_role_id)
    end

    def revoke_admin(user_id:)
      sql = <<~SQL
        DELETE FROM user_role
        WHERE user_id = $1::int AND role_id = $2::int;
      SQL
      @query_runner.run_query(sql, user_id, admin_role_id)
    end

    private

    def admin_role_id
      sql = 'SELECT role_id FROM role WHERE name = $1::text;'
      @query_runner.run_query(sql, 'Admin').first['role_id'].to_i
    end

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

    def sign_in_user_query
      <<~SQL
        WITH selected_user AS (
          SELECT COALESCE(
            (
              SELECT user_id FROM users
              WHERE lower(email) = lower($1::text)
              LIMIT 1
            ),
            (
              SELECT user_id FROM users
              WHERE user_name = $1::text
              LIMIT 1
            )
          ) AS user_id
        )
        SELECT
          users.user_id,
          users.user_name,
          users.email,
          users.pword,
          string_agg(role.name, ', ') AS roles
        FROM users
        INNER JOIN selected_user ON users.user_id = selected_user.user_id
        LEFT JOIN user_role ON users.user_id = user_role.user_id
        LEFT JOIN role ON user_role.role_id = role.role_id
        GROUP BY users.user_id, users.user_name, users.email, users.pword;
      SQL
    end

    def row_to_users_details_hash(row)
      { user_id: row['user_id'].to_i,
        user_name: row['user_name'],
        email: row['email'],
        roles: row['roles'] }
    end
  end
end
