defmodule OdbcEcto.Adapter.Postgres do
  use Ecto.Adapters.SQL, driver: :odbc_ecto, migration_lock: "FOR UPDATE"

  @behaviour Ecto.Adapter.Storage

  def supports_ddl_transaction?, do: true

  @impl true
  defdelegate storage_down(options), to: OdbcEcto.Adapter.Postgres.Storage

  @impl true
  defdelegate storage_up(options), to: OdbcEcto.Adapter.Postgres.Storage
end
