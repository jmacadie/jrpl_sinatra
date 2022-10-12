require 'open3'
require 'rake'
require 'rake/testtask'
require 'rubocop/rake_task'

desc 'Run all tests and Rubocop'
task default: [:test, :rubocop]

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*_test.rb']
end

RuboCop::RakeTask.new(:rubocop) do |t|
  t.patterns = ['src/**/*.rb']
  t.options = ['--display-cop-names']
end

desc 'Run the development server. If pass the paramter \'clean\', will recreate the database before we bgein'
task :run, :clean do |t, args|
  args.with_defaults(:clean => false)
  sh "bundle install"
  if args[:clean]
    Rake::Task["db:build"].invoke('jrpl_dev')
    Rake::Task["db:seed"].invoke('jrpl_dev')
  end
  sh "shotgun"
end

task :run_test do
  Rake::Task["db:build"].invoke('jrpl_test')
  Rake::Task["db:seed"].invoke('jrpl_test', 'test/test_data.sql')
  sh "APP_ENV=test shotgun"
end

namespace :db do
  desc 'Destroy the database, if it exists, and recreate a fresh one from the scripts in data. Takes an argument for the DB name'
  task :build, [:db_name] do |t, args|
    shell "psql -c \"SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '#{args[:db_name]}';\""
    shell "psql -c \"DROP DATABASE IF EXISTS #{args[:db_name]};\""
    shell "psql -c \"CREATE DATABASE #{args[:db_name]};\""
    shell "psql -d #{args[:db_name]} -f 'data/schema.sql';"
  end

  task :seed, [:db_name, :data_file] do |t, args|
    args.with_defaults(:data_file => 'data/wc_2022_data.sql')
    shell "psql -d #{args[:db_name]} -f #{args[:data_file]};"
  end
end

# Couldn't get a built in command to suppress stdout and stderr, so rolled my own
def shell(cmd, print_stdout=false, print_stderr=false)
  puts cmd
  stdout, stderr, status = Open3.capture3(cmd)
  puts stdout if print_stdout
  puts stderr if print_stderr
end