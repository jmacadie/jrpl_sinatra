# Agent Instructions

This is a Ruby/Sinatra project.

## General approach

* Read the surrounding code before making changes.
* If unsure of code structure, read docs/architecture.md
* Follow the existing structure and style.
* Prefer small, focused changes.
* Do not introduce new gems unless explicitly asked or clearly justified.
* Preserve existing behaviour unless the task explicitly asks for a behaviour change.
* Avoid large rewrites unless requested.

## Verification

After making code changes, run:

```sh
bundle exec rake
```

This should run the test suite and RuboCop checks.

A task is not complete until `bundle exec rake` passes.

If `bundle exec rake` fails:

* Investigate the failure.
* Fix any failure caused by your changes.
* You can re-check failing tests in just one test file more, by running `bundle exec rake test TEST={test_file_name}`
* Re-run `bundle exec rake`.
* Do not report success while tests or RuboCop are failing.

If the failure appears unrelated to your changes, report it clearly in the final response and include the relevant error output.

## Tests

* Add or update tests for behaviour changes.
* For bug fixes, add a regression test where practical.
* Do not weaken or remove tests just to make the suite pass.
* Prefer testing observable behaviour over implementation details.

## RuboCop

* Keep RuboCop passing.
* Do not disable cops unless there is a clear reason.
* Do not use broad file-level disables where a narrow local disable would do.
* Prefer idiomatic Ruby over fighting RuboCop.

## Sinatra conventions

* Keep route handlers simple.
* Move repeated view logic into helpers or partials.
* Avoid duplicating ERB across views.
* Keep persistence/database code separate from routing code.
* Validate and sanitize user input at the boundary.

## Security

* Do not change authentication, session, password, or remember-me behaviour casually.
* Treat raw ERB output as risky.
* Do not introduce new uses of unescaped HTML unless explicitly justified.
* Be careful with redirects, user-controlled params, and database queries.

## Final response

When finished, report:

* What changed.
* What verification was run.
* Whether `bundle exec rake` passed.
* Any known caveats or follow-up work.

