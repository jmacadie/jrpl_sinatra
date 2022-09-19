# The Julian Rimet Prediction League

JRPL is a spectator sports prediction league.

JRPL was developed using the ruby web application library 'Sinatra'.
This uses the Rack server interface.
PostgreSQL is used to store the database behind the application.

To run this application locally on your machine:
  - Copy the files into their own project directory
  - Install [Ruby and Budler](https://www.jetbrains.com/help/ruby/set-up-a-ruby-development-environment.html), if needed
  - Install [Postgres](https://www.postgresql.org/docs/14/install-binaries.html), if needed
  - Open up a Command Line Interface application (e.g. iTerm, VSCode, SublimeText)
  - Start the Postgres server: `sudo service postgresql start`
  - Navigate to the jrpl project directory
  - Create the JPRL DB running the following queries (subsituting USER_NAME for your postgres role):
    - `$ psql USER_NAME -c "DROP DATABASE IF EXISTS jrpl_dev"`
    - `$ psql USER_NAME -c "CREATE DATABASE jrpl_dev"`
    - `$ psql USER_NAME -d jrpl_dev -f schema.sql`
    - `$ psql USER_NAME -d jrpl_dev -f wc_2022_data.sql`
  - Install any missing gems: `$ bundle install`
  - Boot the server with: `$ shotgun`
  - Open a browser and navigate to: http://localhost:9393

Once you open the application:
  - The administrator has a username of 'Maccas', password 'a'
  - Non-administrator user is 'Clare Mac', password 'a'

To run the tests:
  - Open a separate CLI
  - Navigate to the jrpl project directory
  - Run: $ ruby test/jrpl_test.rb

To run rubocop (to check for coding style violations):
  - Run: $ rubocop filename.rb
