require_relative '../../helpers/test_helpers'

class EmailsSentRepositoryTest < Minitest::Test
  def test_records_prediction_emails
    query_runner = FakeQueryRunner.new
    repository = Repositories::EmailsSent.new(query_runner:)

    repository.record_predictions_sent(6)

    assert_includes query_runner.calls[0][0], 'predictions_sent = true'
    assert_equal 6, query_runner.calls[0][1]
  end

  def test_records_result_emails
    query_runner = FakeQueryRunner.new
    repository = Repositories::EmailsSent.new(query_runner:)

    repository.record_results_sent(7)

    assert_includes query_runner.calls[0][0], 'results_sent = true'
    assert_equal 7, query_runner.calls[0][1]
  end

  class FakeQueryRunner
    attr_reader :calls

    def initialize
      @calls = []
    end

    def run_query(statement, *params)
      calls << [statement, *params]
    end
  end
end
