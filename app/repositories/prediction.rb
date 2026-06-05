class PredictionRepository
  def initialize(query_runner:)
    @query_runner = query_runner
  end

  def predictions_for_match(match_id)
    result = @query_runner.run_query(predictions_for_match_query, match_id)
    result.map do |row|
      { pred_id: row['prediction_id'].to_i,
        home_score: row['home_team_points'].to_i,
        away_score: row['away_team_points'].to_i }
    end
  end

  def add_prediction(user_id, match_id, home_team_points, away_team_points)
    delete_prediction(user_id, match_id)
    @query_runner.run_query(
      insert_prediction_query,
      user_id,
      match_id,
      home_team_points,
      away_team_points
    )
  end

  private

  def delete_prediction(user_id, match_id)
    @query_runner.run_query(delete_prediction_query, user_id, match_id)
  end

  def predictions_for_match_query
    <<~SQL
      SELECT
        prediction_id,
        home_team_points,
        away_team_points
      FROM prediction
      WHERE match_id = $1::int;
    SQL
  end

  def delete_prediction_query
    <<~SQL
      DELETE FROM prediction
      WHERE user_id = $1::int AND match_id = $2::int;
    SQL
  end

  def insert_prediction_query
    <<~SQL
      INSERT INTO prediction
        (user_id, match_id, home_team_points, away_team_points)
      VALUES ($1::int, $2::int, $3::int, $4::int);
    SQL
  end
end
