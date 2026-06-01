module DBTournamentRoles
  def tournament_roles
    sql = tournament_roles_query()
    result = run_query(sql)
    result = map_tournament_roles(result)
    transform_tournament_roles(result)
  end

  def set_tournament_role(role, team)
    sql = <<~SQL
    UPDATE tournament_role
    SET team_id = $2::int
    WHERE tournament_role_id = $1::int;
    SQL
    run_query(sql, role, team)
  end

  def reset_tournament_role(role)
    sql = <<~SQL
    UPDATE tournament_role
    SET team_id = NULL
    WHERE tournament_role_id = $1::int;
    SQL
    run_query(sql, role)
  end

  def tournament_role_numbers
    sql = <<~SQL
    SELECT MAX(team_id) AS max FROM team
    UNION ALL
    SELECT MAX(tournament_role_id) as max FROM tournament_role;
    SQL
    result = run_query(sql)
    result.map { |row| row['max'].to_i }
  end

  def tournament_role_name(role_id)
    sql = <<~SQL
    SELECT name
    FROM tournament_role
    WHERE tournament_role_id = $1::int;
    SQL
    result = run_query(sql, role_id)
    result.map { |row| row['name'] }.first
  end

  def team_name(team_id)
    sql = <<~SQL
    SELECT name
    FROM team
    WHERE team_id = $1::int;
    SQL
    result = run_query(sql, team_id)
    result.map { |row| row['name'] }.first
  end

  def tournament_role_team_selected_in_stage?(role_id, team_id)
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
    result = run_query(sql, role_id, team_id)
    result.first['selected'] == 't'
  end

  private

  def map_tournament_roles(result)
    result.map do |row|
      {
        stage: row['stage'],
        role: row['tournament_role'],
        id: row['tournament_role_id'],
        selected_team_id: row['selected_team_id'].to_i,
        team_id: row['team_id'].to_i,
        team: row['team']
      }
    end
  end

  def transform_tournament_roles(result)
    stages = unique_stages(result)
    stages.each do |stage|
      roles = tournament_roles_for_stage(result, stage[:stage])
      stage[:group_roles] = add_teams_to_role(result, roles)
    end
  end

  def unique_stages(result)
    result.map { |row| { stage: row[:stage] } }.uniq
  end

  def tournament_roles_for_stage(result, stage)
    result.filter { |row| row[:stage] == stage }
          .map do |row|
            {
              role: row[:role],
              id: row[:id],
              selected: row[:selected_team_id]
            }
          end.uniq
  end

  def add_teams_to_role(result, roles)
    roles.each do |role|
      other_selected = roles.filter { |other| other[:id] != role[:id] }
                            .filter { |other| other[:selected] > 0 }
                            .map { |other| other[:selected] }
                            .uniq
      role[:teams] = teams_for_role(result, role[:id], other_selected)
    end
  end

  def teams_for_role(result, role_id, other_selected)
    result.filter { |row| row[:id] == role_id }
          .map do |row|
            id = row[:team_id]
            {
              team_id: id,
              team_name: row[:team],
              disabled: other_selected.include?(id)
            }
          end
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
