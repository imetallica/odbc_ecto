defmodule OdbcEcto.Adapter.Postgres.Connection do
  @behaviour Ecto.Adapters.SQL.Connection

  @impl true
  def child_spec(options) do
    DBConnection.child_spec(OdbcEcto.Connection, options)
  end

  def stream(_, _, _, _) do
    raise "not implemented"
  end

  @impl true
  def prepare_execute(connection, name, statement, params, options) do
    OdbcEcto.prepare_execute(connection, name, statement, params, options)
  end
end
