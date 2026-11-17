# dagger ruby/RoR example

A small Rails app checked with the [dagger/ruby](https://github.com/dagger/ruby) modules, and a
Minitest test that starts Postgres through a generated module client.

## Layout

- `app/`, `config/`, `db/schema.rb`, `test/`: a Rails 8.1 app on SQLite.
- `test/integration/postgres_container_test.rb`: starts Postgres from the Postgres module and queries it.
- `.dagger/modules/postgres/`: a Ruby SDK module whose `service` returns a Postgres service.
- `.dagger/modules/rails/`: a Ruby SDK module whose `test` check runs `bin/rails test` and whose `server`
  serves the app.
- `dagger.toml`, `dagger.lock`: the workspace modules and their pinned refs.
- `sdk/`, `clients/`, `dagger.gemfile`: the generated Ruby SDK and module client, `test` group only. Do not edit them.

## Commands

| Command | What it does |
| --- | --- |
| `dagger check` | Runs every check, including `rubocop:lint`, `rails:test`, `bundler-audit:audit` and `brakeman:scan`. |
| `dagger check rails:test` | Runs `bin/rails test`, including the Postgres test. |
| `dagger generate` | Regenerates `sdk/` and `clients/`. |
| `dagger start` | Serves Postgres on port 5432 and the Rails app on port 3000. |
| `dagger start postgres:service` | Serves Postgres on port 5432. |
| `dagger start rails:server` | Serves only the Rails app on http://localhost:3000. |

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
tests that use a module client must run from a module in this repository. `.dagger/modules/rails`, in
Ruby, replaces dagger/ruby's `rails` module and calls its `ruby` module through a module client. The
upstream `rails:assets` function is gone: the example has lint, test, audit, scan and a development
server, but no asset build.

## Pinning

`dagger.toml` installs dagger/ruby's `rubocop`, `bundler-audit` and `brakeman` modules from `@main`;
`dagger.lock` pins `main` to one commit, and `dagger lock update` moves it. The rails scope in
`dagger.toml` pins the `ruby` module client to commit `8cb0f24`.
