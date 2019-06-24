defmodule OdbcEcto.Connection.ODBC do
  @moduledoc """
  This module makes it work `:odbc` with `DBConnection`.
  """
  defstruct [:conn]

  use GenServer

  alias OdbcEcto.Error

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def stop(pid, reason) do
    GenServer.stop(pid, {:shutdown, reason})
  end

  def query(pid, %OdbcEcto.Query{statement: statement} = query) do
    case GenServer.call(pid, {:query, statement}, :infinity) do
      {:ok, result} -> {:ok, query, result}
      {:error, reason} -> {:error, reason}
    end
  end

  def query(pid, %OdbcEcto.Query{statement: statement} = query, params) do
    case GenServer.call(pid, {:query, statement, params}, :infinity) do
      {:ok, result} -> {:ok, query, result}
      {:error, reason} -> {:error, reason}
    end
  end

  def init(opts) do
    conn_str = Keyword.get(opts, :conn_str, "")
    timeout = Keyword.get(opts, :timeout, 5000)

    case :odbc.connect(to_charlist(conn_str), timeout: timeout, binary_strings: :on) do
      {:ok, ref} ->
        {:ok, %__MODULE__{conn: ref}}

      {:error, reason} ->
        {:stop, %Error{message: "error when connecting: #{inspect(to_string(reason))}"}}
    end
  end

  def terminate({:shutdown, err}, state) do
    case :odbc.disconnect(state.conn) do
      {:error, reason} ->
        {:error,
         %Error{
           message:
             "error when disconnecting: #{inspect(reason)}. DBConnection error: #{inspect(err)}"
         }}

      :ok ->
        :ok
    end
  end

  def terminate(reason, state) do
    super(reason, state)
  end

  def handle_call({:query, statement}, _from, state) do
    case :odbc.sql_query(state.conn, to_charlist(statement), :infinity) do
      {:selected, col_names, rows} ->
        {:reply, {:ok, %OdbcEcto.Result{colums: col_names, rows: rows}}, state}

      {:updated, rows} ->
        {:reply, {:ok, %OdbcEcto.Result{rows: rows}}, state}
    end
  end

  def handle_call({:query, statement, params}, _from, state) do
    case :odbc.param_query(state.conn, to_charlist(statement), params, :infinity) do
      {:selected, col_names, rows} ->
        {:reply, {:ok, %OdbcEcto.Result{colums: col_names, rows: rows}}, state}

      {:updated, rows} ->
        {:reply, {:ok, %OdbcEcto.Result{rows: rows}}, state}
    end
  end
end
