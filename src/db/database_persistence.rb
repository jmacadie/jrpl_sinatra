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

  def initialize(logger, conf)
    hash = {dbname: conf['database']}
    hash[:host] = conf['host'] if not conf['host'].nil?
    hash[:port] = conf['port'] if not conf['port'].nil?
    hash[:user] = conf['username'] if not conf['username'].nil?
    hash[:password] = conf['password'] if not conf['password'].nil?
    @db = PG.connect(**hash)
    @logger = logger
  end

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
