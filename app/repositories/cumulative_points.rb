module Repositories
  class CumulativePoints
    def initialize(query_runner:)
      @query_runner = query_runner
    end

    def load_cumulative_point_rows
      result = @query_runner.run_query(cumulative_points_query)
      result.map { |row| map_cumulative_point(row) }
    end

    private

    def map_cumulative_point(row)
      {
        match_id: row['match_id'],
        match: row['match_desc'],
        user_id: row['user_id'],
        user_name: row['user_name'],
        cum_points: row['cum_points']
      }
    end

    def cumulative_points_query
      <<~SQL
        WITH all_users AS
          (SELECT user_id FROM users)

        ,sorted_matches AS
          (SELECT
            match_id,
            ROW_NUMBER() OVER
              (ORDER BY date, kick_off) AS match_sort
          FROM match)

        ,points_by_match AS
          (SELECT
            m.match_id,
            u.user_id,
            COALESCE(po.total_points, 0) AS total_points

          FROM match m
            CROSS JOIN all_users u
            LEFT JOIN prediction pred ON
              pred.match_id = m.match_id
              AND pred.user_id = u.user_id
            LEFT JOIN points po ON
              po.prediction_id = pred.prediction_id

          WHERE
            m.home_team_points IS NOT NULL
            AND m.away_team_points IS NOT NULL
            AND COALESCE(po.scoring_system_id, 1) = 1)

        SELECT
          pbm.match_id,
          CONCAT(COALESCE(hot.name, htr.name), ' vs ', COALESCE(awt.name, atr.name)) AS match_desc,
          pbm.user_id,
          u.user_name,
          SUM(pbm.total_points) OVER
            (PARTITION BY pbm.user_id
             ORDER BY sm.match_sort) AS cum_points

        FROM points_by_match pbm
          INNER JOIN sorted_matches sm ON
            sm.match_id = pbm.match_id
          INNER JOIN match m ON
            m.match_id = pbm.match_id
          INNER JOIN tournament_role htr ON
            htr.tournament_role_id = m.home_team_id
          LEFT JOIN team hot ON
            hot.team_id = htr.team_id
          INNER JOIN tournament_role atr ON
            atr.tournament_role_id = m.away_team_id
          LEFT JOIN team awt ON
            awt.team_id = atr.team_id
          INNER JOIN users u ON
            pbm.user_id = u.user_id

        ORDER BY sm.match_sort, UPPER(u.user_name);
      SQL
    end
  end
end
