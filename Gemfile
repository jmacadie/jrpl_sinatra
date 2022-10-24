source 'https://rubygems.org'

gem 'base64'
gem 'bcrypt'
gem 'concurrent-ruby'
gem 'erubis'
gem 'pg'
gem 'pony'
gem 'securerandom'
gem 'sinatra'
gem 'sinatra-contrib'
gem 'yaml'
gem 'zlib'

group :development do
  gem 'debug'
  gem 'open3'
  gem 'pry'
  gem 'rake'
  # https://dev.to/dnamsons/ruby-debugging-in-vscode-3bkj
  # rdebug-ide --host 0.0.0.0 --port 1234 --dispatcher-port 26162 /path/to/the/file.rb
  gem 'ruby-debug-ide'
  gem 'shotgun'
end

group :test do
  gem 'minitest'
  gem 'rack-test'
  gem 'simplecov'
end

group :production do
  gem 'puma'
end
