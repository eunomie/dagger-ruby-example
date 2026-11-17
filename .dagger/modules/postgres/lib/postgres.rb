require "dagger"
require "dagger/clients/roots"

class Postgres
  extend Dagger::Mod::Object
  include Dagger::Clients::Roots

  description "A disposable Postgres server for tests"

  function "Postgres 17 from the official image, listening on 5432 with user and password `postgres`."
  #: () -> Dagger::Clients::Core::Service
  def service
    core.container.from(address: "postgres:17-alpine")
        .with_env_variable(name: "POSTGRES_PASSWORD", value: "postgres")
        .with_exposed_port(port: 5432)
        .as_service
  end
end
