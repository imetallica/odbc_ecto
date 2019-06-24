defmodule OdbcEcto do
  @moduledoc """
  Documentation for OdbcEcto.
  """

  @doc """
  Starts the OdbcEcto connection.
  """
  def start_link(opts) do
    DBConnection.start_link(OdbcEcto.Connection, opts)
  end

  def prepare_execute(conn, name, statement, params, opts) do
    IO.inspect(name, label: "NAME")

    query = %OdbcEcto.Query{statement: statement}
    DBConnection.prepare_execute(conn, query, params, opts)
  end
end
