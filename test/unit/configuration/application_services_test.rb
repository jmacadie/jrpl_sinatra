require "test_helpers"

class ApplicationServicesTest < Minitest::Test
  REPOSITORY_CLASSES = [
    Repositories::QueryRunner,
    Repositories::Cookie,
    Repositories::CumulativePoints,
    Repositories::EmailsSent,
    Repositories::Fixtures,
    Repositories::Match,
    Repositories::Prediction,
    Repositories::TournamentRole,
    Repositories::User,
    Repositories::Point
  ].freeze

  REGISTERED_COMPONENTS = {
    query_runner: Repositories::QueryRunner,
    cookie_repository: Repositories::Cookie,
    user_repository: Repositories::User,
    edit_user_service: Services::Accounts::EditUser,
    remember_me_login_service: Services::Accounts::RememberMe,
    sign_in_service: Services::Accounts::SignIn,
    sign_up_service: Services::Accounts::SignUp,
    match_broadcaster_service: Services::Admin::Broadcaster,
    delete_user_service: Services::Admin::DeleteUser,
    reset_user_password_service: Services::Admin::ResetUserPassword,
    match_result_service: Services::Admin::Result,
    tournament_role_service: Services::Admin::TournamentRole,
    toggle_user_admin_service: Services::Admin::ToggleUserAdmin,
    lockdown_service: Services::Core::Lockdown,
    match_prediction_service: Services::Core::Prediction,
    email_sender: Services::Mailers::EmailSender,
    admin_page_service: Services::Pages::Admin,
    edit_user_page_service: Services::Pages::EditUser,
    fixtures_page_service: Services::Pages::Fixtures,
    graphs_page_service: Services::Pages::Graphs,
    match_page_service: Services::Pages::Match,
    tables_page_service: Services::Pages::Tables
  }.freeze

  SERVICE_DEPENDENCIES = {
    Services::Accounts::EditUser => {
      user_repository: Repositories::User
    },
    Services::Accounts::RememberMe => {
      cookie_repository: Repositories::Cookie,
      token_generator: Proc
    },
    Services::Accounts::SignIn => {
      user_repository: Repositories::User
    },
    Services::Accounts::SignUp => {
      user_repository: Repositories::User
    },
    Services::Admin::Broadcaster => {
      match_repository: Repositories::Match
    },
    Services::Admin::DeleteUser => {
      user_repository: Repositories::User
    },
    Services::Admin::ResetUserPassword => {
      user_repository: Repositories::User
    },
    Services::Admin::Result => {
      match_repository: Repositories::Match,
      scoreboard_service: Services::Core::Scoreboard,
      result_mailer: Services::Mailers::Result,
      lockdown_policy: Policies::Lockdown
    },
    Services::Admin::ToggleUserAdmin => {
      user_repository: Repositories::User
    },
    Services::Admin::TournamentRole => {
      tournament_role_repository: Repositories::TournamentRole
    },
    Services::Core::Lockdown => {
      match_repository: Repositories::Match,
      mr_men_service: Services::Core::MrMen,
      predictions_mailer: Services::Mailers::Predictions,
      lockdown_policy: Policies::Lockdown
    },
    Services::Mailers::Predictions => {
      match_repository: Repositories::Match,
      prediction_repository: Repositories::Prediction,
      emails_sent_repository: Repositories::EmailsSent,
      renderer: Renderers::SinatraTemplate,
      email_sender: Services::Mailers::EmailSender
    },
    Services::Core::MrMen => {
      prediction_repository: Repositories::Prediction
    },
    Services::Core::Prediction => {
      match_repository: Repositories::Match,
      prediction_repository: Repositories::Prediction,
      lockdown_policy: Policies::Lockdown
    },
    Services::Mailers::Result => {
      match_repository: Repositories::Match,
      prediction_repository: Repositories::Prediction,
      scoreboard_service: Services::Core::Scoreboard,
      renderer: Renderers::SinatraTemplate,
      email_sender: Services::Mailers::EmailSender,
      emails_sent_repository: Repositories::EmailsSent
    },
    Services::Core::Scoreboard => {
      match_repository: Repositories::Match,
      prediction_repository: Repositories::Prediction,
      point_repository: Repositories::Point
    },
    Services::Pages::Admin => {
      user_repository: Repositories::User,
      tournament_role_repository: Repositories::TournamentRole
    },
    Services::Pages::EditUser => {
      user_repository: Repositories::User
    },
    Services::Pages::Fixtures => {
      fixtures_repository: Repositories::Fixtures
    },
    Services::Pages::Graphs => {
      cumulative_points_repository: Repositories::CumulativePoints,
      user_repository: Repositories::User
    },
    Services::Pages::Match => {
      match_repository: Repositories::Match,
      prediction_repository: Repositories::Prediction,
      user_repository: Repositories::User,
      lockdown_policy: Policies::Lockdown
    },
    Services::Pages::Tables => {
      point_repository: Repositories::Point
    }
  }.freeze

  def test_registers_public_components_on_the_app
    app = FakeApp.new

    ApplicationServices.new(app:).register

    REGISTERED_COMPONENTS.each do |name, component_class|
      assert_instance_of component_class, app.settings.public_send(name)
    end
  end

  def test_wires_shared_infrastructure_and_repositories
    app = FakeApp.new
    classes = [Services::Mailers::EmailSender,
               *REPOSITORY_CLASSES]

    with_constructor_spies(classes) do |calls|
      ApplicationServices.new(app:).register

      assert_query_runner_wiring(app, calls)
      assert_repository_wiring(app, calls)
      assert_email_sender_wiring(app, calls)
    end
  end

  def test_wires_services_with_expected_collaborator_types
    app = FakeApp.new

    with_constructor_spies(SERVICE_DEPENDENCIES.keys) do |calls|
      ApplicationServices.new(app:).register

      SERVICE_DEPENDENCIES.each do |service_class, dependencies|
        assert_dependency_types(constructor_keywords(calls, service_class),
                                dependencies)
      end
    end
  end

  private

  def assert_query_runner_wiring(app, calls)
    dependencies = constructor_keywords(calls, Repositories::QueryRunner)

    assert_same app.settings.db_pool, dependencies.fetch(:db_pool)
    assert_same app.environment, dependencies.fetch(:environment)
    assert_instance_of Logger, dependencies.fetch(:logger)
  end

  def assert_repository_wiring(app, calls)
    REPOSITORY_CLASSES.each do |repository_class|
      dependencies = constructor_keywords(calls, repository_class)

      if repository_class == Repositories::QueryRunner
        assert_equal [:db_pool, :logger, :environment], dependencies.keys
      else
        assert_equal [:query_runner], dependencies.keys
        assert_same app.settings.query_runner,
                    dependencies.fetch(:query_runner)
      end
    end
  end

  def assert_email_sender_wiring(app, calls)
    dependencies = constructor_keywords(calls, Services::Mailers::EmailSender)

    assert_same app.settings.query_runner, dependencies.fetch(:query_runner)
    assert_same app.settings.email, dependencies.fetch(:config)
    assert_same app.environment, dependencies.fetch(:environment)
  end

  def assert_dependency_types(actual, expected)
    assert_equal expected.keys.sort, actual.keys.sort
    expected.each do |name, collaborator_class|
      assert_instance_of collaborator_class, actual.fetch(name)
    end
  end

  def constructor_keywords(calls, component_class)
    component_calls = calls.fetch(component_class)

    assert_equal 1, component_calls.length
    component_calls.first.fetch(:keywords)
  end

  def with_constructor_spies(classes, calls = nil, &)
    calls ||= constructor_calls
    component_class, *remaining_classes = classes
    return yield calls if component_class.nil?

    with_constructor_spy(component_class, calls) do
      with_constructor_spies(remaining_classes, calls, &)
    end
  end

  def constructor_calls
    Hash.new { |hash, key| hash[key] = [] }
  end

  def with_constructor_spy(component_class, calls)
    singleton_class = component_class.singleton_class
    had_own_constructor = singleton_class.public_method_defined?(:new, false)
    original_constructor = singleton_class.instance_method(:new)
    singleton_class.define_method(
      :new,
      constructor_spy(component_class, original_constructor, calls)
    )
    yield
  ensure
    restore_constructor(singleton_class, original_constructor,
                        had_own_constructor)
  end

  def constructor_spy(component_class, original_constructor, calls)
    lambda do |*arguments, **keywords, &constructor_block|
      calls[component_class] << { arguments:, keywords: }
      original_constructor.bind_call(
        component_class, *arguments, **keywords, &constructor_block
      )
    end
  end

  def restore_constructor(singleton_class, constructor, had_own_constructor)
    singleton_class.send(:remove_method, :new) if
      singleton_class.public_method_defined?(:new, false)
    singleton_class.define_method(:new, constructor) if had_own_constructor
  end

  class FakeApp
    attr_reader :environment, :settings

    def initialize
      @environment = :test
      @settings = FakeSettings.new(
        db_pool: Object.new,
        email: { 'from' => 'test@example.com' }
      )
    end

    def set(name, value)
      settings.set(name, value)
    end

    def new!
      Object.new
    end
  end

  class FakeSettings
    def initialize(values)
      @values = values
    end

    def set(name, value)
      @values[name] = value
    end

    def method_missing(name, *arguments)
      return @values.fetch(name) if arguments.empty? && @values.key?(name)

      super
    end

    def respond_to_missing?(name, include_private = false)
      @values.key?(name) || super
    end
  end
end
