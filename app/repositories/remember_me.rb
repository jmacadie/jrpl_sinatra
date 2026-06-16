module Repositories
  class RememberMe
    def initialize(query_runner:)
      @query_runner = query_runner
    end

    def delete_cookie_data(series_id:)
      return if series_id.nil?

      sql = <<~SQL
        DELETE FROM remember_me
        WHERE series_id = $1::text;
      SQL
      @query_runner.run_query(sql, series_id)
    end

    def save_new_cookie(user_id:, series_id:, token_digest:)
      sql = <<~SQL
        INSERT INTO remember_me
        VALUES ($1::int, $2::text, $3::text, $4::timestamp);
      SQL
      @query_runner.run_query(
        sql,
        user_id,
        series_id,
        token_digest,
        Time.now
      )
    end

    def update_token(series_id:, token_digest:)
      sql = <<~SQL
        UPDATE remember_me
        SET token = $1::text, date_added = $2::timestamp
        WHERE series_id = $3::text;
      SQL
      @query_runner.run_query(sql, token_digest, Time.now, series_id)
    end

    def series_id_list
      result = @query_runner.run_query(
        'SELECT series_id FROM remember_me;'
      )
      result.map { |row| row['series_id'] }
    end

    def user_from_series(series_id:)
      sql = <<~SQL
        SELECT user_id, token
        FROM remember_me
        WHERE series_id = $1::text;
      SQL
      result = @query_runner.run_query(sql, series_id)
      return nil if result.ntuples.zero?

      row = result.first
      { user_id: row['user_id'].to_i, token: row['token'] }
    end
  end
end
