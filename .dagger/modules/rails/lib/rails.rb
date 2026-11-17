require "dagger"
require "dagger/clients/roots"

class Rails
  extend Dagger::Mod::Object
  include Dagger::Clients::Roots

  description "Runs `bin/rails test` from this repository's own module, so the generated " \
              "clients the tests load resolve their local paths against this repository."

  function "Run `bin/rails test` in the workspace root and fail with its output.", check: true
  #: (ws: Dagger::Clients::Core::Workspace) -> void
  def test(ws:)
    # Not ruby.run: its exec would run in the ruby module, where client paths do not resolve.
    ran = ruby.container(ws:).with_exec(args: ["bin/rails", "test"], expect: Dagger::Clients::Core::ReturnType::ANY)
    raise "Rails tests failed:\n#{ran.stdout}#{ran.stderr}" unless ran.exit_code.zero?
  end

  function "Serve the app in development with `bin/rails server` on port 3000, after `bin/rails db:prepare`. " \
           "Rails only answers its development hosts, such as localhost.", start: true
  #: (ws: Dagger::Clients::Core::Workspace) -> Dagger::Clients::Core::Service
  def server(ws:)
    ruby.container(ws:)
        .with_exec(args: ["bin/rails", "db:prepare"])
        .with_exposed_port(port: 3000)
        .as_service(args: ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"])
  end
end
