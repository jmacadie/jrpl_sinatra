require_relative '../helpers/test_helpers'

class ResetUserPasswordServiceTest < Minitest::Test
  def test_resets_password_and_returns_message
    repository = FakeUserRepository.new
    service = ResetUserPasswordService.new(user_repository: repository)

    result = service.call(user_name: 'Clare Mac')

    assert_equal(
      "The password has been reset to 'jrpl' for Clare Mac.",
      result.message
    )
    assert_equal [
      [:reset_password, 'Clare Mac', 'jrpl']
    ], repository.calls
  end

  class FakeUserRepository
    attr_reader :calls

    def initialize
      @calls = []
    end

    def reset_password(user_name, password)
      calls << [:reset_password, user_name, password]
    end
  end
end
