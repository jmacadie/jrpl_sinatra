module Presenters
  class CumulativePoints
    def initialize(rows)
      @rows = normalize_numbers(rows)
    end

    def grouped_points
      unique_matches.each do |match|
        match[:users] = users_for_match(match[:match_id])
      end
    end

    private

    def normalize_numbers(rows)
      rows.map do |row|
        row.merge(
          match_id: row[:match_id].to_i,
          user_id: row[:user_id].to_i,
          cum_points: row[:cum_points].to_i
        )
      end
    end

    def unique_matches
      @rows.map do |row|
        {
          match_id: row[:match_id],
          match: row[:match]
        }
      end.uniq
    end

    def users_for_match(match_id)
      @rows.filter { |row| row[:match_id] == match_id }
           .map do |row|
             {
               user_id: row[:user_id],
               user_name: row[:user_name],
               cum_points: row[:cum_points]
             }
           end
    end
  end
end
