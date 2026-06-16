require "test_helpers"

class ResetUserPasswordServiceTest < Minitest::Test
  def test_resets_password_and_returns_message
    repository = FakeUserRepository.new
    hasher = FakeHasher.new('scrambled_jrpl')
    service = Services::Admin::ResetUserPassword.new(
      user_repository: repository,
      hasher: hasher
    )

    result = service.call(user_name: 'Clare Mac')

    assert_equal(
      "The password has been reset to 'jrpl' for Clare Mac.",
      result.message
    )
    assert_equal [
      [:reset_password, 'Clare Mac', 'scrambled_jrpl']
    ], repository.calls
    assert_equal [
      [:hash, 'jrpl']
    ], hasher.calls
  end

  class FakeUserRepository
    attr_reader :calls

    def initialize
      @calls = []
    end

    def reset_password(user_name:, digest:)
      calls << [:reset_password, user_name, digest]
    end
  end

  class FakeHasher
    attr_reader :calls

    def initialize(digest)
      @calls = []
      @digest = digest
    end

    def hash(password:)
      calls << [:hash, password]
      @digest
    end
  end
end
