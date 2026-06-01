# Architecture Overview

JRPL is a Sinatra application backed by PostgreSQL. The codebase is organised around a thin web layer, a helper-heavy request lifecycle, and a set of database modules that keep SQL grouped by domain.

## Boot Sequence

The Rack entrypoint is [`config.ru`](../config.ru), which loads [`app/application.rb`](../app/application.rb) and runs `App`.

`app/application.rb` does the framework setup:

- enables sessions and CSRF protection
- sets the app paths for views, helpers, config, tests, and public assets
- loads `config/general.yml` into Sinatra settings
- creates the PostgreSQL connection pool from `config/database.yml`
- configures email delivery through Pony
- extends shared helper modules before every request
- runs the lockdown check in a `before` filter

The app boot path is intentionally simple. Most behaviour is pushed into helper modules and database modules instead of being embedded directly in the route handlers.

## Application Layers

### Routes

Controllers under [`app/controllers`](../app/controllers) define Sinatra routes for the major screens and actions:

- [`home.rb`](../app/controllers/home.rb): homepage and fallback redirect
- [`users.rb`](../app/controllers/users.rb): sign in, sign out, sign up, and account changes
- [`match.rb`](../app/controllers/match.rb): match details, predictions, results, and broadcaster updates
- [`fixtures.rb`](../app/controllers/fixtures.rb): fixture filtering and session-backed criteria
- [`tables.rb`](../app/controllers/tables.rb): scoreboard tables
- [`graphs.rb`](../app/controllers/graphs.rb): cumulative points graphs
- [`rules.rb`](../app/controllers/rules.rb): rules page
- [`admin.rb`](../app/controllers/admin.rb): admin dashboard
- [`tournament_role.rb`](../app/controllers/tournament_role.rb): tournament role assignment

Routes are usually short. They validate access, load the relevant data, set a small number of instance variables, and render an ERB template or redirect.

### Helpers

Route and view helper behaviour lives under [`app/helpers`](../app/helpers). These modules provide request/session support for controllers and presentation helpers for ERB:

- [`auth.rb`](../app/helpers/auth.rb): login state, account validation, admin checks
- [`login_cookies.rb`](../app/helpers/login_cookies.rb): remember-me cookies and token rotation
- [`route_helpers.rb`](../app/helpers/route_helpers.rb): fixture criteria and lockdown timing
- [`route_errors.rb`](../app/helpers/route_errors.rb): user-facing validation messages
- [`view_helpers.rb`](../app/helpers/view_helpers.rb): display formatting for ERB

Application services and utilities live under [`app/services`](../app/services):

- [`query.rb`](../app/services/query.rb): PostgreSQL connection and query helpers used by repositories
- [`scoring.rb`](../app/services/scoring.rb): official points calculation
- [`lockdown.rb`](../app/services/lockdown.rb): lock-window checks and notifications
- [`email.rb`](../app/services/email.rb): Pony integration and environment-specific mail config
- [`mr_men.rb`](../app/services/mr_men.rb): aggregate Mr Mean, Mr Median, and Mr Mode predictions
- [`ring.rb`](../app/services/ring.rb): compact match navigation token

This split keeps controllers focused on orchestration while the reusable rules stay in one place.

### Database Modules

The files in [`app/repositories`](../app/repositories) are the persistence boundary. Each file groups SQL around one concern:

- [`users.rb`](../app/repositories/users.rb): users and admin role links
- [`login.rb`](../app/repositories/login.rb): credential persistence
- [`cookies.rb`](../app/repositories/cookies.rb): remember-me persistence
- [`matches.rb`](../app/repositories/matches.rb): match detail queries and writes
- [`matches_full.rb`](../app/repositories/matches_full.rb): fixture listing queries
- [`match_predictions.rb`](../app/repositories/match_predictions.rb): per-match prediction views
- [`points.rb`](../app/repositories/points.rb): scoreboard persistence and aggregation
- [`cumulative_points.rb`](../app/repositories/cumulative_points.rb): graph data
- [`tournament_roles.rb`](../app/repositories/tournament_roles.rb): tournament bracket and role mapping
- [`emails.rb`](../app/repositories/emails.rb): email sent flags

The controllers and helpers call these modules directly rather than introducing a separate service layer. That keeps the data access patterns explicit and easy to trace.

### Views and Assets

Templates live under [`app/views`](../app/views). The app uses ERB with shared layout fragments for:

- the main site chrome
- match detail subviews
- fixtures filters
- tables and graphs
- email bodies

Client-side behaviour lives in [`public/js`](../public/js), with styling and images under [`public/css`](../public/css) and [`public/img`](../public/img).

## Operational Notes

- PostgreSQL schema and seed data live in [`data`](../data).
- Local development, test setup, and database rebuilds are driven by the Rake tasks in [`Rakefile`](../Rakefile).
- Deployment scripts live in [`scripts`](../scripts).

## Notable Implementation Choices

- Authentication is session-based, with optional persistent login cookies backed by the `remember_me` table.
- Lockdown is time-based and enforced both in the UI and in the server-side validation paths.
- Scoreboard data is derived from the stored predictions and points rows rather than being cached in a separate read model.
- The match navigation ring is encoded into a compact string so the current match and surrounding order can be preserved in URLs.
- Mail delivery is synchronous and happens inside the request path for lockdown and result actions.
