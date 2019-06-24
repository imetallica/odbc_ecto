defmodule OdbcEcto.Connection do
  use DBConnection

  alias OdbcEcto.Connection.ODBC

  @impl true
  def connect(opts) do
    ODBC.start_link(opts)
  end

  @impl true
  def disconnect(err, state) do
    ODBC.stop(state, err)
  end

  @impl true
  def checkin(state) do
    {:ok, state}
  end

  @impl true
  def checkout(state) do
    {:ok, state}
  end

  @impl true
  def ping(state) do
    {:ok, state}
  end

  @impl true
  def handle_prepare(%OdbcEcto.Query{statement: _statement} = query, _opts, state) do
    IO.inspect(query, label: "1")
    {:ok, query, state}
  end

  @impl true
  def handle_execute(%OdbcEcto.Query{} = query, [], _opts, state) do
    IO.inspect("123", label: "=====")

    case ODBC.query(state, query) do
      {:ok, query, result} ->
        {:ok, query, result, state}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def handle_execute(%OdbcEcto.Query{} = query, params, _opts, state) do
    IO.inspect(params, label: "=====")

    case ODBC.query(state, query, params) do
      {:ok, query, result} ->
        {:ok, query, result, state}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
