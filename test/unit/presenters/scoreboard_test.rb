require 'test_helpers'

class ScoreboardPresenterTest < Minitest::Test
  def test_adds_basic_ranking
    tables = scoreboard_tables(
      overall_table: [
        scoreboard_row('Clare Mac', 5),
        scoreboard_row('Maccas', 3),
        scoreboard_row('Mr. Mean', 1)
      ]
    )

    ranked = Presenters::Scoreboard.new(tables).ranked_tables

    assert_equal %w(1 2 3), ranks(ranked[:overall_table])
  end

  def test_marks_ties_and_skips_ranks_after_ties
    tables = scoreboard_tables(
      overall_table: [
        scoreboard_row('Clare Mac', 5),
        scoreboard_row('Maccas', 5),
        scoreboard_row('Mr. Mean', 3),
        scoreboard_row('Mr. Happy', 3),
        scoreboard_row('Mr. Grumpy', 1)
      ]
    )

    ranked = Presenters::Scoreboard.new(tables).ranked_tables

    assert_equal ['1=', '1=', '3=', '3=', '5'], ranks(ranked[:overall_table])
  end

  def test_handles_empty_tables
    ranked = Presenters::Scoreboard.new(scoreboard_tables).ranked_tables

    assert_empty ranked[:overall_table]
    assert_empty ranked[:group_table]
    assert_empty ranked[:knockout_table]
  end

  def test_ranks_each_scoreboard_table
    tables = scoreboard_tables(
      overall_table: [
        scoreboard_row('Clare Mac', 3),
        scoreboard_row('Maccas', 1)
      ],
      group_table: [
        scoreboard_row('Maccas', 2),
        scoreboard_row('Clare Mac', 2)
      ],
      knockout_table: [
        scoreboard_row('Mr. Mean', 1)
      ]
    )

    ranked = Presenters::Scoreboard.new(tables).ranked_tables

    assert_equal %w(1 2), ranks(ranked[:overall_table])
    assert_equal ['1=', '1='], ranks(ranked[:group_table])
    assert_equal ['1'], ranks(ranked[:knockout_table])
  end

  private

  def scoreboard_tables(overall_table: [], group_table: [],
                        knockout_table: [])
    { overall_table:, group_table:, knockout_table: }
  end

  def scoreboard_row(user_name, total_points)
    { user_name:, total_points: }
  end

  def ranks(table)
    table.map { |row| row[:rank] }
  end
end
