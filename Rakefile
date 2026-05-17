require 'open3'
require 'rake'
require 'rake/testtask'
require 'rubocop/rake_task'
require 'socket'

desc 'Run all tests and Rubocop'
task default: [:test, :rubocop]

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*_test.rb']
end

RuboCop::RakeTask.new(:rubocop) do |t|
  t.patterns = ['src/**/*.rb', 'test/**/*.rb', 'Rakefile', 'Gemfile']
  t.options = ['--display-cop-names']
end

desc 'Run the development server. ' \
     'If pass the paramter \'clean\', will recreate the database before we ' \
     'begin'
task :run, :clean do |_t, args|
  args.with_defaults(clean: false)
  ensure_mailpit_running
  sh "bundle install"
  sh "scripts/restore_configs.rb"
  if args[:clean]
    Rake::Task["db:build"].invoke('jrpl_dev')
    Rake::Task["db:seed"].invoke('jrpl_dev')
  end
  sh "bundle exec rackup -s puma -p 4567 config.ru"
end

task :run_test do
  sh "scripts/restore_configs.rb"
  Rake::Task["db:build"].invoke('jrpl_test')
  Rake::Task["db:seed"].invoke('jrpl_test', 'data/test_data.sql')
  sh "APP_ENV=test bundle exec rackup -s puma -p 5678 config.ru"
end

namespace :db do
  desc 'Destroy the database. ' \
       'If it exists, and recreate a fresh one from the scripts in data. ' \
       'Takes an argument for the DB name'
  task :build, [:db_name] do |_t, args|
    shell "psql -c \"SELECT pg_terminate_backend(pid) " \
          "FROM pg_stat_activity WHERE datname = '#{args[:db_name]}';\""
    shell "psql -c \"DROP DATABASE IF EXISTS #{args[:db_name]};\""
    shell "psql -c \"CREATE DATABASE #{args[:db_name]};\""
    shell "psql -d #{args[:db_name]} -f 'data/schema_wc.sql';"
  end

  task :seed, [:db_name, :data_file] do |_t, args|
    args.with_defaults(data_file: 'data/wc_2026_data.sql')
    shell "psql -d #{args[:db_name]} -f '#{args[:data_file]}';"
  end
end

# Couldn't get a built in command to suppress stdout and stderr,
# so rolled my own
def shell(cmd, print_stdout: false, print_stderr: false)
  puts cmd
  stdout, stderr, = Open3.capture3(cmd)
  puts stdout if print_stdout
  puts stderr if print_stderr
end

def port_open?(host, port)
  Socket.tcp(host, port, connect_timeout: 1) { true }
rescue Errno::ECONNREFUSED,
       Errno::EHOSTUNREACH,
       Errno::ENETUNREACH,
       Errno::ETIMEDOUT,
       SocketError
  false
end

MAILPIT_HOST = '127.0.0.1'
MAILPIT_SMTP_PORT = 1025
MAILPIT_WEB_PORT = 8025

def ensure_mailpit_running
  return if port_open?(MAILPIT_HOST, MAILPIT_SMTP_PORT)

  puts 'Starting Mailpit...'
  pid = spawn_mailpit()

  at_exit do
    next unless pid
    kill_mailpit(pid)
  end

  sleep 1
  check_mailpit()
end

def spawn_mailpit
  spawn(
    'mailpit',
    '--smtp', "#{MAILPIT_HOST}:#{MAILPIT_SMTP_PORT}",
    '--listen', "#{MAILPIT_HOST}:#{MAILPIT_WEB_PORT}",
    out: '/tmp/mailpit.log',
    err: '/tmp/mailpit.log'
  )
end

def check_mailpit
  unless port_open?(MAILPIT_HOST, MAILPIT_SMTP_PORT)
    abort 'Mailpit failed to start. Check /tmp/mailpit.log'
  end

  puts "Mailpit running at http://localhost:#{MAILPIT_WEB_PORT}"
end

def kill_mailpit(pid)
  puts 'Stopping Mailpit...'
  Process.kill('TERM', pid)
  Process.wait(pid)
rescue Errno::ESRCH, Errno::ECHILD
  # already gone
end
