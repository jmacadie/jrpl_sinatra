# rubocop:disable Metrics/ModuleLength
module DBPoints
  def add_points(pred_id, scoring_system_id, result_pts, score_pts)
    delete_existing_points_entry(pred_id, scoring_system_id)
    sql = insert_into_points_table_query()
    query(
      sql,
      pred_id,
      scoring_system_id,
      result_pts,
      score_pts,
      result_pts + score_pts
    )
  end

  def id_for_scoring_system(scoring_system)
    sql = 'SELECT scoring_system_id FROM scoring_system WHERE name = $1::text;'
    query(sql, scoring_system).map do |tuple|
      tuple['scoring_system_id']
    end.first.to_i
  end

  def load_scoreboard_data(scoring_system)
    scoring_system_id = id_for_scoring_system(scoring_system)
    overall_table = load_one_scoreboard_data(scoring_system_id, :all)
    group_table = load_one_scoreboard_data(scoring_system_id, :group)
    knockout_table = load_one_scoreboard_data(scoring_system_id, :knockout)
    { overall_table:, group_table:, knockout_table: }
  end

  private

  def load_one_scoreboard_data(scoring_system_id, stage)
    sql = select_users_points_query(stage)
    result = query(sql, scoring_system_id)
    result = tuple_to_table_hash(result)
    add_rank(result)
  end

  # rubocop:disable Metrics/MethodLength
  def add_rank(table)
    rank_str = ''
    last_points = -1
    table.each_with_index do |user, index|
      if user[:total_points] != last_points
        rank_str = (index + 1).to_s
        # rubocop:disable Layout/LineLength
        rank_str += '=' if index < (table.size - 1) &&
                           user[:total_points] == table[index + 1][:total_points]
        # rubocop:enable Layout/LineLength
        last_points = user[:total_points]
      end
      user[:rank] = rank_str
    end
  end
  # rubocop:enable Metrics/MethodLength

  def tuple_to_table_hash(result)
    result.map do |tuple|
      { user_id: tuple['user_id'],
        user_name: tuple['user_name'],
        result_points: tuple['result_points'].to_i,
        score_points: tuple['score_points'].to_i,
        total_points: tuple['result_points'].to_i + tuple['score_points'].to_i }
    end
  end

  def delete_existing_points_entry(pred_id, scoring_system_id)
    sql = <<~SQL
      DELETE FROM points
      WHERE prediction_id = $1::int AND scoring_system_id = $2::int;
    SQL
    query(sql, pred_id, scoring_system_id)
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

  def update_points_table_query
    <<~SQL
      UPDATE points
      SET result_points = $1::int, score_points = $2::int, total_points = $3::int
      WHERE (prediction_id = $4 AND scoring_system_id = $5);
    SQL
  end
end
# rubocop:enable Metrics/ModuleLength
