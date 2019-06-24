defmodule OdbcEcto.Adapter.Postgres.Connection do
  @behaviour Ecto.Adapters.SQL.Connection

  @impl true
  def child_spec(options) do
    OdbcEcto.child_spec(options)
  end

  @impl true
  def prepare_execute(connection, name, statement, params, options) do
    OdbcEcto.prepare_execute(connection, name, statement, params, options)
  end
end
