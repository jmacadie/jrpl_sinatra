module MrMen
  def calc_mr_men(match_id)
    @predictions = @storage.get_match_predictions(match_id)
    prep_predictions()
    calc_mr_mean(match_id)
    calc_mr_median(match_id)
    calc_mr_mode(match_id)
  end

  private

  def prep_predictions
    home = @predictions
           .map { |pred| pred[:home_prediction] }
           .compact
           .sort
    away = @predictions
           .map { |pred| pred[:away_prediction] }
           .compact
           .sort
    @preds = { home:, away: }
  end

  def calc_mr_mean(match_id)
    home = mean(@preds[:home])
    away = mean(@preds[:away])
    @storage.add_prediction(1, match_id, home, away)
  end

  def mean(array)
    return 0 if array.empty?
    (array.sum(0.0) / array.size).round
  end

  def calc_mr_median(match_id)
    home = median(@preds[:home])
    away = median(@preds[:away])
    @storage.add_prediction(2, match_id, home, away)
  end

  def median(array)
    return 0 if array.empty?
    idx = array.size / 2
    if array.size.even?
      mean(array[idx - 1, 2])
    else
      array[idx]
    end
  end

  def calc_mr_mode(match_id)
    home = mode(@preds[:home])
    away = mode(@preds[:away])
    @storage.add_prediction(3, match_id, home, away)
  end

  def mode(array)
    return 0 if array.empty?
    tallied = array.tally
    sorted = tallied.sort_by { |_, v| -v }
    max_count = sorted.first[1]
    mode_preds = sorted
                 .filter { |_, v| v == max_count }
                 .map { |k, _| k }
    mean(mode_preds)
  end
end
