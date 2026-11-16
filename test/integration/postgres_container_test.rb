require "test_helper"
require "dagger"
require "dagger/clients/postgres"

class PostgresContainerTest < ActiveSupport::TestCase
  setup do
    service = Dagger::Clients::Postgres.postgres.service
    @tunnel = Dagger::Clients::Core.core.host.tunnel(service:).start
    @db = connect(URI(@tunnel.endpoint(scheme: "postgres")))
  end

  teardown do
    @db&.close
    @tunnel&.stop
  end

  test "writes and reads a row in a Postgres started by the Postgres module" do
    @db.exec("CREATE TEMP TABLE greetings (name text NOT NULL)")
    @db.exec_params("INSERT INTO greetings (name) VALUES ($1)", ["Ada"])

    assert_equal ["Ada"], @db.exec("SELECT name FROM greetings").column_values(0)
  end

  private

  # The service reports started before Postgres accepts connections.
  def connect(endpoint)
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 30
    begin
      PG.connect(host: endpoint.host, port: endpoint.port, user: "postgres", password: "postgres",
                 connect_timeout: 2)
    rescue PG::ConnectionBad
      raise if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline

      sleep 1
      retry
    end
  end
end
