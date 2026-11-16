# dagger ruby/RoR example

A small Rails app checked with the [dagger/ruby](https://github.com/dagger/ruby) modules, and a
Minitest test that starts Postgres through a generated module client.

## Layout

- `app/`, `config/`, `db/schema.rb`, `test/`: a Rails 8.1 app on SQLite.
- `test/integration/postgres_container_test.rb`: starts Postgres from the Postgres module and queries it.
- `.dagger/modules/postgres/`: a local Dang module whose `service` returns a Postgres service.
- `.dagger/modules/rails/`: a local Dang module whose `test` check runs `bin/rails test`.
- `dagger.toml`, `dagger.lock`: the workspace modules and their pinned refs.
- `sdk/`, `clients/`, `dagger.gemfile`: the generated Ruby SDK and module client, `test` group only. Do not edit them.

## Commands

| Command | What it does |
| --- | --- |
| `dagger check` | Runs every check, including `rubocop:lint`, `rails:test`, `bundler-audit:audit` and `brakeman:scan`. |
| `dagger check rails:test` | Runs `bin/rails test`, including the Postgres test. |
| `dagger generate` | Regenerates `sdk/` and `clients/`. |
| `dagger start postgres:service` | Serves Postgres on port 5432. |

## Test dependencies as code

A test declares the Postgres it needs as a Dagger module and starts it through the module client,
with no mocks and no docker compose. The test tunnels `Dagger::Clients::Postgres.postgres.service` to
the host with `host.tunnel` and queries it with a raw `pg` connection, not the app's SQLite database.

How the module client was generated:

```sh
dagger module install github.com/dagger/ruby-sdk@v1.1.0
dagger module client add -y ./.dagger/modules/postgres
```

To run the test on the host, use Ruby 3.4 or later and a git checkout, because the session needs a
git workspace to find `dagger.toml`.

```sh
bundle install
dagger run bin/rails test test/integration
```

## Why a local `rails` module

The engine resolves a module client's local module path against the module that runs the code, so
tests that use a module client must run from a module in this repository. `.dagger/modules/rails`
replaces dagger/ruby's `rails` module and reuses its `ruby` module. The upstream `rails:server` and
`rails:assets` functions are gone: the example has lint, test, audit and scan, but no asset build.
Serve the app on the host with `bin/rails db:prepare` and then `bin/rails server`.

## Pinning

`dagger.toml` installs dagger/ruby's `rubocop`, `bundler-audit` and `brakeman` modules from `@main`;
`dagger.lock` pins `main` to one commit, and `dagger lock update` moves it.
`.dagger/modules/rails/dagger-module.toml` pins dagger/ruby's `ruby` module to commit `8cb0f24`.
