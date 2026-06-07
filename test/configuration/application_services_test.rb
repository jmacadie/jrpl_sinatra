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
    query_runner: QueryRunner,
    cookie_repository: CookieRepository,
    user_repository: UserRepository,
    email_sender: EmailSender,
    lockdown_service: LockdownService,
    match_result_service: MatchResultService,
    match_prediction_service: MatchPredictionService,
    match_page_service: MatchPageService,
    match_broadcaster_service: MatchBroadcasterService,
    fixtures_page_service: FixturesPageService,
    graphs_page_service: GraphsPageService,
    tables_page_service: TablesPageService,
    admin_page_service: AdminPageService,
    tournament_role_service: TournamentRoleService,
    edit_user_page_service: EditUserPageService,
    edit_user_service: EditUserService,
    sign_in_service: SignInService,
    sign_up_service: SignUpService,
    reset_user_password_service: ResetUserPasswordService,
    delete_user_service: DeleteUserService,
    toggle_user_admin_service: ToggleUserAdminService
  }.freeze

  SERVICE_DEPENDENCIES = {
    MrMenService => {
      prediction_repository: PredictionRepository
    },
    LockdownService => {
      match_repository: MatchRepository,
      prediction_repository: PredictionRepository,
      emails_sent_repository: EmailsSentRepository,
      mr_men_service: MrMenService,
      renderer: SinatraTemplateRenderer,
      email_sender: EmailSender
    },
    ScoreboardService => {
      match_repository: MatchRepository,
      prediction_repository: PredictionRepository,
      point_repository: PointRepository
    },
    MatchResultMailer => {
      match_repository: MatchRepository,
      prediction_repository: PredictionRepository,
      scoreboard_service: ScoreboardService,
      renderer: SinatraTemplateRenderer,
      email_sender: EmailSender,
      emails_sent_repository: EmailsSentRepository
    },
    MatchResultService => {
      match_repository: MatchRepository,
      scoreboard_service: ScoreboardService,
      result_mailer: MatchResultMailer
    },
    MatchPredictionService => {
      match_repository: MatchRepository,
      prediction_repository: PredictionRepository
    },
    MatchPageService => {
      match_repository: MatchRepository,
      prediction_repository: PredictionRepository,
      user_repository: UserRepository
    },
    MatchBroadcasterService => {
      match_repository: MatchRepository
    },
    FixturesPageService => {
      fixtures_repository: FixturesRepository
    },
    GraphsPageService => {
      cumulative_points_repository: CumulativePointsRepository,
      user_repository: UserRepository
    },
    TablesPageService => {
      point_repository: PointRepository
    },
    AdminPageService => {
      user_repository: UserRepository,
      tournament_role_repository: TournamentRoleRepository
    },
    TournamentRoleService => {
      tournament_role_repository: TournamentRoleRepository
    },
    EditUserPageService => {
      user_repository: UserRepository
    },
    EditUserService => {
      user_repository: UserRepository
    },
    SignInService => {
      user_repository: UserRepository
    },
    SignUpService => {
      user_repository: UserRepository
    },
    ResetUserPasswordService => {
      user_repository: UserRepository
    },
    DeleteUserService => {
      user_repository: UserRepository
    },
    ToggleUserAdminService => {
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
    classes = [QueryRunner, EmailSender, *REPOSITORY_CLASSES]

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
    dependencies = constructor_keywords(calls, QueryRunner)

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
    dependencies = constructor_keywords(calls, EmailSender)

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
