module Repositories
  class EmailsSent
    def initialize(query_runner:)
      @query_runner = query_runner
    end

    def record_predictions_sent(match_id:)
      sql =
        <<~SQL
        INSERT INTO emails (match_id, predictions_sent, results_sent)
        VALUES ($1::int, true, false)
        ON CONFLICT (match_id)
        DO UPDATE
        SET
          predictions_sent = true;
        SQL
      @query_runner.run_query(sql, match_id)
    end

    def record_results_sent(match_id:)
      sql = 'UPDATE emails SET results_sent = true WHERE match_id = $1::int'
      @query_runner.run_query(sql, match_id)
    end
  end
end
