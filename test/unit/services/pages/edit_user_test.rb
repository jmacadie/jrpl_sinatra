require "test_helpers"

class EditUserPageServiceTest < Minitest::Test
  def test_loads_current_user_for_editing
    repository = FakeUserRepository.new
    service = Services::Pages::EditUser.new(user_repository: repository)

    page = service.call(user_id: 11)

    assert_equal(
      {
        user_id: 11,
        user_name: 'Clare Mac',
        email: 'clare@macadie.co.uk',
        roles: nil
      },
      page.user
    )
    assert_equal [[:load_user_details, 11]], repository.calls
  end

  class FakeUserRepository
    attr_reader :calls

    def initialize
      @calls = []
    end

    def load_user_details(user_id)
      calls << [:load_user_details, user_id]
      {
        user_id:,
        user_name: 'Clare Mac',
        email: 'clare@macadie.co.uk',
        roles: nil
      }
    end
  end
end
