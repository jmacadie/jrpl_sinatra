# The Julian Rimet Prediction League

JRPL is a spectator sports prediction league.

JRPL was developed using the ruby web application library 'Sinatra'.
This uses the Rack server interface.
PostgreSQL is used to store the database behind the application.

## Run locally

To run this application locally on your machine:
  - Copy the files into their own project directory
  - Install [Ruby and Bundler](https://www.jetbrains.com/help/ruby/set-up-a-ruby-development-environment.html), if needed
  - Install [Postgres](https://www.postgresql.org/docs/14/install-binaries.html), if needed
  - Start the Postgres server: `sudo service postgresql start`
  - Update the gems with `bundle update`
  - If running v0.9.2 of shotgun then we need to [monkey patch the code as it doesn't work with Ruby 3.x](https://github.com/rtomayko/shotgun/issues/76)
  - Also need to monkey patch WEBrick::HTTPServer::run on line 109:
      `if req.keep_alive? && res.keep_alive? && req.request_method != "POST"`
    Can't find anyone else on the webs talking about this but without the last guard `fixup` gets called but the `server.service(req, res)` line a few above has already read the body off the socket and so the `fixup` call ends up with a timeout while it waits for an empty socket to yield more bytes
  - Run the project with rake: `bundle exec rake run\[true\]`
    - On subsequent runs only need `bundle exec rake run`: the true parameter tells rake to recreate the database
  - Open a browser and navigate to: http://localhost:9393

Once you open the application:
  - The administrator has a username of 'Maccas', password 'a'
  - Non-administrator user is 'Clare Mac', password 'a'

To run the tests:
  - `bundle exec rake test`

To run rubocop (to check for coding style violations):
  - `bundle exec rake rubocop`

To run both tests and Rubocop, run the default rake task:
  - `bundle exec rake`

## Deploy

To deploy, it is assumed that you will be following [this bootstrap process](https://github.com/jmacadie/bootstrap-server/tree/main/ruby).
  - Once all dependencies are installed / set-up, run `./create_new_app.sh` to get the skeleton set up
    - To reset & start again `./wipe_app.sh` can be run
    - You can verify this worked by using any browser to navigate to the app domain. You should get a "You rock..." page
  - Navigate to `/var/www/{APP_NAME}`
  - Run the `./deploy.sh` script to pull in the latest version of the code and to create a release from it
  - The first time an app is deployed:
    - You need to set up the database. Run the script `scripts/reset_db.sh {APP_NAME}` to deploy a fresh copy from the source script
    - You need to provide the system settings in `config/database.yml` and `config/general.yml`. This must be done by hand for security.
      - The database passwords are provided in the text output of `./create_new_app.sh`
      - On subsequent deploys, you can elect to keep the config settings to avoid having to re-input

With all this the website should be good to go in production / staging on the webserver
