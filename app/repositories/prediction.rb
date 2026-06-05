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

  private

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
end
