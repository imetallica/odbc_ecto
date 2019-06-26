defmodule OdbcEcto.Adapter.Postgres.Storage do
  @behaviour Ecto.Adapter.Storage

  @impl true
  def storage_down(options) do
    with {:conn_str, conn_str} when not is_nil(conn_str) <-
           {:conn_str, Keyword.get(options, :conn_str)},
         {:db_name, db_name} when not is_nil(db_name) <- {:db_name, get_database_name(conn_str)},
         {:edit_conn_str, edited_conn_str} <- {:edit_conn_str, remove_database_name(conn_str)},
         {:ok, conn} <- OdbcEcto.start_link(conn_str: edited_conn_str),
         {:ok, result, value} <-
           OdbcEcto.prepare_execute(conn, "", "DROP DATABASE \"#{db_name}\""),
         _ = GenServer.stop(conn) do
      IO.inspect(result)
      IO.inspect(value)
      :ok
    else
      {:conn_str, nil} -> {:error, "empty connection string"}
      {:db_name, nil} -> {:error, "database name not given"}
      err -> err
    end
  end

  @impl true
  def storage_up(options) do
    IO.inspect(options)
  end

  defp get_database_name(conn_str) do
    unless is_nil(conn_str) do
      conn_str
      |> String.split(";")
      |> Enum.find("|", &String.match?(&1, ~r/database/iu))
      |> String.split("=")
      |> tl()
      |> List.first()
    end
  end

  defp remove_database_name(conn_str) do
    unless is_nil(conn_str) do
      conn_str
      |> String.split(";")
      |> Enum.filter(fn s -> not String.match?(s, ~r/database/iu) end)
      |> Enum.join()
    end
  end
end
