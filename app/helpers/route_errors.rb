module RouteErrors
  def not_integer?(num)
    !(num.floor - num).zero?
  end

  def prediction_type_error(home_prediction, away_prediction)
    error = []
    error << 'integers' if
      not_integer?(home_prediction) || not_integer?(away_prediction)
    error << 'non-negative' if
      home_prediction < 0 || away_prediction < 0
    return nil if error.empty?
    "Your predictions must be #{error.join(' and ')}."
  end

  def prediction_error(match, home_prediction, away_prediction)
    if match_locked_down?(match)
      'You cannot add or change your prediction because ' \
        'this match is already locked down!'
    else
      prediction_type_error(home_prediction, away_prediction)
    end
  end
end
