Logger.configure(level: :info)

ExUnit.start(exclude: [])

# Configure Ecto for support and tests
Application.put_env(:ecto, :primary_key_type, :id)
Application.put_env(:ecto, :lock_for_update, "FOR UPDATE")

pool =
  case System.get_env("ECTO_POOL") || "poolboy" do
    "poolboy" -> DBConnection.Poolboy
    "sbroker" -> DBConnection.Sojourn
  end

Code.require_file("./support/repo.exs", __DIR__)

alias Ecto.Integration.TestRepo

Application.put_env(
  :ecto,
  TestRepo,
  adapter: OdbcEcto.Adapter.Postgres,
  conn_str: System.get_env("TEST_CONN_STR"),
  pool: Ecto.Adapters.SQL.Sandbox,
  ownership_pool: pool
)

alias Ecto.Integration.PoolRepo

Application.put_env(
  :ecto,
  PoolRepo,
  adapter: OdbcEcto.Adapter.Postgres,
  pool: pool,
  conn_str: System.get_env("POOL_CONN_STR"),
  pool_size: 10,
  max_restarts: 20,
  max_seconds: 10
)

# Basic test repo

defmodule Ecto.Integration.TestRepo do
  use Ecto.Integration.Repo, otp_app: :ecto, adapter: OdbcEcto.Adapter.Postgres
end

# Pool repo for transaction and lock tests
defmodule Ecto.Integration.PoolRepo do
  use Ecto.Integration.Repo, otp_app: :ecto, adapter: OdbcEcto.Adapter.Postgres

  def create_prefix(prefix) do
    "create schema #{prefix}"
  end

  def drop_prefix(prefix) do
    "drop schema #{prefix}"
  end
end

defmodule Ecto.Integration.Case do
  use ExUnit.CaseTemplate

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TestRepo)
  end
end

# Load support files
Code.require_file("./support/types.exs", __DIR__)
Code.require_file("./support/file_helpers.exs", __DIR__)
Code.require_file("./support/schemas.exs", __DIR__)
Code.require_file("./support/migration.exs", __DIR__)

{:ok, _} = OdbcEcto.Adapter.Postgres.ensure_all_started(TestRepo, :temporary)

# Load up the repository, start it, and run migrations
_ = OdbcEcto.Adapter.Postgres.storage_down(TestRepo.config())
:ok = OdbcEcto.Adapter.Postgres.storage_up(TestRepo.config())

{:ok, _pid} = TestRepo.start_link()
{:ok, _pid} = PoolRepo.start_link()

:ok = Ecto.Migrator.up(TestRepo, 0, Ecto.Integration.Migration, log: false)
Ecto.Adapters.SQL.Sandbox.mode(TestRepo, :manual)
Process.flag(:trap_exit, true)
