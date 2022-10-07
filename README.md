# The Julian Rimet Prediction League

JRPL is a spectator sports prediction league.

JRPL was developed using the ruby web application library 'Sinatra'.
This uses the Rack server interface.
PostgreSQL is used to store the database behind the application.

To run this application locally on your machine:
  - Copy the files into their own project directory
  - Install [Ruby and Budler](https://www.jetbrains.com/help/ruby/set-up-a-ruby-development-environment.html), if needed
  - Install [Postgres](https://www.postgresql.org/docs/14/install-binaries.html), if needed
  - Start the Postgres server: `$ sudo service postgresql start`
  - Run the project with rake: `$ rake run[true]` (N.B. Need the gem `rake` installed first: `$ gem install rake`)
    - On subsequent runs only need `$ rake run`: the true paramenter tells rake to recreate the database
  - Open a browser and navigate to: http://localhost:9393

Once you open the application:
  - The administrator has a username of 'Maccas', password 'a'
  - Non-administrator user is 'Clare Mac', password 'a'

To run the tests:
  - `$ rake test`

To run rubocop (to check for coding style violations):
  - `$ rake rubocop`

To run both tests and Rubocop, run the default rake task:
  - `$ rake`
