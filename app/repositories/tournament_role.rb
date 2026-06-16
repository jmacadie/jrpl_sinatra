module Repositories
  class TournamentRole
    def initialize(query_runner:)
      @query_runner = query_runner
    end

    def load_role_rows
      result = @query_runner.run_query(tournament_roles_query)
      result.map { |row| map_tournament_role(row) }
    end

    def set_team(role_id:, team_id:)
      sql = <<~SQL
        UPDATE tournament_role
        SET team_id = $2::int
        WHERE tournament_role_id = $1::int;
      SQL
      @query_runner.run_query(sql, role_id, team_id)
    end

    def reset_team(role_id:)
      sql = <<~SQL
        UPDATE tournament_role
        SET team_id = NULL
        WHERE tournament_role_id = $1::int;
      SQL
      @query_runner.run_query(sql, role_id)
    end

    def role_numbers
      sql = <<~SQL
        SELECT MAX(team_id) AS max FROM team
        UNION ALL
        SELECT MAX(tournament_role_id) as max FROM tournament_role;
      SQL
      result = @query_runner.run_query(sql)
      result.map { |row| row['max'].to_i }
    end

    def role_name(role_id:)
      sql = <<~SQL
        SELECT name
        FROM tournament_role
        WHERE tournament_role_id = $1::int;
      SQL
      result = @query_runner.run_query(sql, role_id)
      result.map { |row| row['name'] }.first
    end

    def team_name(team_id:)
      sql = <<~SQL
        SELECT name
        FROM team
        WHERE team_id = $1::int;
      SQL
      result = @query_runner.run_query(sql, team_id)
      result.map { |row| row['name'] }.first
    end

    def team_selected_in_stage?(role_id:, team_id:)
      sql = <<~SQL
        SELECT EXISTS (
          SELECT 1
          FROM tournament_role tr
          WHERE tr.stage_id = (
            SELECT stage_id
            FROM tournament_role
            WHERE tournament_role_id = $1::int
          )
            AND tr.team_id = $2::int
            AND tr.tournament_role_id <> $1::int
        ) AS selected;
      SQL
      result = @query_runner.run_query(sql, role_id, team_id)
      result.first['selected'] == 't'
    end

    private

    def map_tournament_role(row)
      {
        stage: row['stage'],
        role: row['tournament_role'],
        id: row['tournament_role_id'],
        selected_team_id: row['selected_team_id'],
        team_id: row['team_id'],
        team: row['team']
      }
    end

    def tournament_roles_query
      <<~SQL
        SELECT
          s.name AS stage,
          tr.name AS tournament_role,
          tr.tournament_role_id AS tournament_role_id,
          t.team_id AS selected_team_id,
          COALESCE(tm.team_id, tg.team_id) AS team_id,
          COALESCE(tm.name, tg.name) AS team

        FROM tournament_role tr
          INNER JOIN stage s ON s.stage_id = tr.stage_id

          -- Selected team
          LEFT JOIN team t ON t.team_id = tr.team_id

          -- Teams from source match
          LEFT JOIN
            (SELECT match_id, home_team_id AS team_id FROM match UNION ALL
             SELECT match_id, away_team_id AS team_id FROM match) m ON
            m.match_id = tr.from_match_id
              LEFT JOIN tournament_role trm ON trm.tournament_role_id = m.team_id
                LEFT JOIN team tm ON tm.team_id = trm.team_id

          -- Teams from source group
          LEFT JOIN meta_group_map mgm ON mgm.meta_group_id = tr.from_group_id
            LEFT JOIN tournament_role trg ON trg.from_group_id = mgm.group_id AND trg.stage_id = 1
              LEFT JOIN team tg ON tg.team_id = trg.team_id

        WHERE tr.stage_id > 1

        ORDER BY s.stage_id, tr.tournament_role_id;
      SQL
    end
  end
end
