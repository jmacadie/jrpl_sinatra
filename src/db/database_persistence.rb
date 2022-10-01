require 'pg'

require_relative 'cookies'
require_relative 'login'
require_relative 'matches'
require_relative 'points'
require_relative 'predictions'
require_relative 'users'

class DatabasePersistence
  include DBPersCookies
  include DBPersLogin
  include DBPersMatches
  include DBPersPoints
  include DBPersPredictions
  include DBPersUsers

  # rubocop:disable Metrics/AbcSize
  def initialize(logger, conf)
    hash = { dbname: conf['database'] }
    hash[:host] = conf['host'] if !conf['host'].nil?
    hash[:port] = conf['port'] if !conf['port'].nil?
    hash[:user] = conf['username'] if !conf['username'].nil?
    hash[:password] = conf['password'] if !conf['password'].nil?
    @db = PG.connect(**hash)
    @logger = logger
  end
  # rubocop:enable Metrics/AbcSize

  def disconnect
    @db.close
  end

  def tournament_stage_names
    sql = 'SELECT name FROM stage;'
    result = query(sql)
    result.map { |tuple| tuple['name'] }
  end

  private

  def convert_str_to_int(str)
    # This is needed because nil.to_i returns 0!!!
    str ? str.to_i : nil
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end
end
