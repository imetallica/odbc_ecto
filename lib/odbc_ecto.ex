defmodule OdbcEcto do
  @moduledoc """
  Documentation for OdbcEcto.
  """

  @doc """
  Starts the OdbcEcto connection.
  """
  def start_link(opts) do
    DBConnection.start_link(OdbcEcto.Connection, opts) |> IO.inspect(label: "1")
  end

  def prepare_execute(conn, _name, statement, params \\ [], opts \\ []) do
    query = %OdbcEcto.Query{statement: statement}
    DBConnection.prepare_execute(conn, query, params, opts)
  end
end
