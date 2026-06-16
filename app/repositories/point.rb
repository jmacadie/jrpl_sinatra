module Repositories
  class Point
    def initialize(query_runner:)
      @query_runner = query_runner
    end

    def add_points(pred_id:, scoring_system_id:, result_pts:, score_pts:)
      delete_existing_points_entry(pred_id, scoring_system_id)
      @query_runner.run_query(
        insert_into_points_table_query,
        pred_id,
        scoring_system_id,
        result_pts,
        score_pts,
        result_pts + score_pts
      )
    end

    def load_scoreboard_data(scoring_system:)
      scoring_system_id = id_for_scoring_system(scoring_system)
      overall_table = load_one_scoreboard_data(scoring_system_id, :all)
      group_table = load_one_scoreboard_data(scoring_system_id, :group)
      knockout_table = load_one_scoreboard_data(scoring_system_id, :knockout)
      { overall_table:, group_table:, knockout_table: }
    end

    private

    def id_for_scoring_system(scoring_system)
      sql = <<~SQL
        SELECT scoring_system_id
        FROM scoring_system
        WHERE name = $1::text;
      SQL
      @query_runner.run_query(sql, scoring_system).map do |row|
        row['scoring_system_id']
      end.first.to_i
    end

    def load_one_scoreboard_data(scoring_system_id, stage)
      result = @query_runner.run_query(select_users_points_query(stage),
                                       scoring_system_id)
      row_to_table_hash(result)
    end

    def row_to_table_hash(result)
      result.map do |row|
        { user_id: row['user_id'],
          user_name: row['user_name'],
          result_points: row['result_points'].to_i,
          score_points: row['score_points'].to_i,
          total_points: row['total_points'].to_i }
      end
    end

    def delete_existing_points_entry(pred_id, scoring_system_id)
      sql = <<~SQL
        DELETE FROM points
        WHERE prediction_id = $1::int AND scoring_system_id = $2::int;
      SQL
      @query_runner.run_query(sql, pred_id, scoring_system_id)
    end

    def insert_into_points_table_query
      <<~SQL
        INSERT INTO points
        (prediction_id, scoring_system_id, result_points, score_points, total_points)
        VALUES ($1::int, $2::int, $3::int, $4::int, $5::int);
      SQL
    end

    # rubocop:disable Metrics/MethodLength
    def select_users_points_query(stage)
      sql = <<~SQL
        SELECT
          users.user_id,
          users.user_name,
          COALESCE(sum(system_points.result_points), 0) AS result_points,
          COALESCE(sum(system_points.score_points), 0) AS score_points,
          COALESCE(sum(system_points.total_points), 0) AS total_points
        FROM users
        LEFT OUTER JOIN prediction ON users.user_id = prediction.user_id
      SQL
      if stage != :all
        sql << "LEFT OUTER JOIN match ON match.match_id = prediction.match_id\n"
      end
      sql << <<~SQL
        LEFT OUTER JOIN
          (SELECT * FROM points WHERE scoring_system_id = $1::int) AS system_points
          ON prediction.prediction_id = system_points.prediction_id
      SQL
      case stage
      when :group
        sql << "WHERE match.stage_id = 1\n"
      when :knockout
        sql << "WHERE match.stage_id > 1\n"
      end
      sql << <<~SQL
        GROUP BY users.user_id
        ORDER BY total_points DESC, score_points DESC, result_points DESC, user_name;
      SQL
      sql
    end
    # rubocop:enable Metrics/MethodLength
  end
end
