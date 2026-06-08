require_relative '../helpers/test_helpers'

class ApplicationServicesTest < Minitest::Test
  REPOSITORY_CLASSES = [
    CookieRepository,
    CumulativePointsRepository,
    EmailsSentRepository,
    FixturesRepository,
    MatchRepository,
    PredictionRepository,
    TournamentRoleRepository,
    UserRepository,
    PointRepository
  ].freeze

  REGISTERED_COMPONENTS = {
    query_runner: Services::QueryRunner,
    cookie_repository: CookieRepository,
    user_repository: UserRepository,
    email_sender: Services::EmailSender,
    lockdown_service: Services::Lockdown,
    match_result_service: Services::MatchResult,
    match_prediction_service: Services::MatchPrediction,
    match_page_service: Services::MatchPage,
    match_broadcaster_service: Services::MatchBroadcaster,
    fixtures_page_service: Services::FixturesPage,
    graphs_page_service: Services::GraphsPage,
    tables_page_service: Services::TablesPage,
    admin_page_service: Services::AdminPage,
    tournament_role_service: Services::TournamentRole,
    edit_user_page_service: Services::EditUserPage,
    edit_user_service: Services::EditUser,
    sign_in_service: Services::SignIn,
    sign_up_service: Services::SignUp,
    reset_user_password_service: Services::ResetUserPassword,
    delete_user_service: Services::DeleteUser,
    toggle_user_admin_service: Services::ToggleUserAdmin
  }.freeze

  SERVICE_DEPENDENCIES = {
    Services::MrMen => {
      prediction_repository: PredictionRepository
    },
    Services::Lockdown => {
      match_repository: MatchRepository,
      prediction_repository: PredictionRepository,
      emails_sent_repository: EmailsSentRepository,
      mr_men_service: Services::MrMen,
      renderer: Services::SinatraTemplateRenderer,
      email_sender: Services::EmailSender
    },
    Services::Scoreboard => {
      match_repository: MatchRepository,
      prediction_repository: PredictionRepository,
      point_repository: PointRepository
    },
    Services::MatchResultMailer => {
      match_repository: MatchRepository,
      prediction_repository: PredictionRepository,
      scoreboard_service: Services::Scoreboard,
      renderer: Services::SinatraTemplateRenderer,
      email_sender: Services::EmailSender,
      emails_sent_repository: EmailsSentRepository
    },
    Services::MatchResult => {
      match_repository: MatchRepository,
      scoreboard_service: Services::Scoreboard,
      result_mailer: Services::MatchResultMailer
    },
    Services::MatchPrediction => {
      match_repository: MatchRepository,
      prediction_repository: PredictionRepository
    },
    Services::MatchPage => {
      match_repository: MatchRepository,
      prediction_repository: PredictionRepository,
      user_repository: UserRepository
    },
    Services::MatchBroadcaster => {
      match_repository: MatchRepository
    },
    Services::FixturesPage => {
      fixtures_repository: FixturesRepository
    },
    Services::GraphsPage => {
      cumulative_points_repository: CumulativePointsRepository,
      user_repository: UserRepository
    },
    Services::TablesPage => {
      point_repository: PointRepository
    },
    Services::AdminPage => {
      user_repository: UserRepository,
      tournament_role_repository: TournamentRoleRepository
    },
    Services::TournamentRole => {
      tournament_role_repository: TournamentRoleRepository
    },
    Services::EditUserPage => {
      user_repository: UserRepository
    },
    Services::EditUser => {
      user_repository: UserRepository
    },
    Services::SignIn => {
      user_repository: UserRepository
    },
    Services::SignUp => {
      user_repository: UserRepository
    },
    Services::ResetUserPassword => {
      user_repository: UserRepository
    },
    Services::DeleteUser => {
      user_repository: UserRepository
    },
    Services::ToggleUserAdmin => {
      user_repository: UserRepository
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
    classes = [Services::QueryRunner,
               Services::EmailSender,
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
    dependencies = constructor_keywords(calls, Services::QueryRunner)

    assert_same app.settings.db_pool, dependencies.fetch(:db_pool)
    assert_same app.environment, dependencies.fetch(:environment)
    assert_instance_of Logger, dependencies.fetch(:logger)
  end

  def assert_repository_wiring(app, calls)
    REPOSITORY_CLASSES.each do |repository_class|
      dependencies = constructor_keywords(calls, repository_class)

      assert_equal [:query_runner], dependencies.keys
      assert_same app.settings.query_runner,
                  dependencies.fetch(:query_runner)
    end
  end

  def assert_email_sender_wiring(app, calls)
    dependencies = constructor_keywords(calls, Services::EmailSender)

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
