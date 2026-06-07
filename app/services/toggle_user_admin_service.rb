class ToggleUserAdminService
  Result = Struct.new(:changed, keyword_init: true)

  def initialize(user_repository:)
    @user_repository = user_repository
  end

  def call(user_id:, action:)
    user_id = user_id.to_i
    case action
    when 'grant_admin'
      grant_admin_result(user_id)
    when 'revoke_admin'
      revoke_admin_result(user_id)
    else
      Result.new(changed: false)
    end
  end

  private

  def grant_admin_result(user_id)
    return Result.new(changed: false) if @user_repository.admin?(user_id)

    @user_repository.grant_admin(user_id)
    Result.new(changed: true)
  end

  def revoke_admin_result(user_id)
    return Result.new(changed: false) unless @user_repository.admin?(user_id)

    @user_repository.revoke_admin(user_id)
    Result.new(changed: true)
  end
end
