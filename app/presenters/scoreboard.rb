module Presenters
  class Scoreboard
    def initialize(tables:)
      @tables = tables
    end

    def call
      @tables.transform_values { |table| add_ranks(table) }
    end

    private

    def add_ranks(table)
      rank = ''
      last_points = -1

      table.each_with_index.map do |user, index|
        if user[:total_points] != last_points
          rank = rank_for(table, index)
          last_points = user[:total_points]
        end

        user.merge(rank:)
      end
    end

    def rank_for(table, index)
      rank = (index + 1).to_s
      next_user = table[index + 1]
      rank += '=' if next_user &&
                     table[index][:total_points] == next_user[:total_points]
      rank
    end
  end
end
