module Presenters
  class Scoreboard
    def initialize(tables:)
      @tables = tables
    end

    def call
      add_extra_tables
      @tables.transform_values { |table| add_ranks(table) }
    end

    private

    def add_extra_tables
      # no_women_no_children_table
      tom_table
      peck_table
    end

    def no_women_no_children_table
      men = %w(4 6 7 8 9 10 11 12 13 14 17 18 19 20 27 28 29 30 31)
      all_table = @tables[:overall_table]
      table = all_table.map(&:clone)
                       .filter { |u| men.include?(u[:user_id]) }
      @tables[:nwnc_table] = table
    end

    def tom_table
      toms = %w(20 30)
      all_table = @tables[:overall_table]
      table = all_table.map(&:clone)
                       .filter { |u| toms.include?(u[:user_id]) }
      @tables[:tom_table] = table
    end

    def peck_table
      pecks = %w(15 16 26 29 30)
      all_table = @tables[:overall_table]
      table = all_table.map(&:clone)
                       .filter { |u| pecks.include?(u[:user_id]) }
      @tables[:peck_table] = table
    end

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
