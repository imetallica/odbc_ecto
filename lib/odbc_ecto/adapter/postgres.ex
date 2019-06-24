defmodule OdbcEcto.Adapter.Postgres do
  use Ecto.Adapters.SQL, driver: :odbc_ecto, migration_lock: "FOR UPDATE"

  def supports_ddl_transaction?, do: true

  def storage_down(opts) do
    raise "not implemented"
  end
end
