defmodule ToDo.Web do
  use Plug.Router

  plug :match
  plug :dispatch

  post "/add_entry" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    title = Map.fetch!(conn.params, "title")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    list_name
    |> ToDo.Cache.server_process()
    |> ToDo.Server.add_entry(%{title: title, date: date})

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, "OK")
  end

  get "/entries" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    date = case Map.fetch(conn.params, "date") do
      {:ok, value} -> Date.from_iso8601!(value)
      :error -> nil
    end

    entries = if is_nil(date) do
      list_name |> ToDo.Cache.server_process() |> ToDo.Server.list_entries()
    else
      list_name |> ToDo.Cache.server_process() |> ToDo.Server.list_entries(date)
    end

    formatted_entries =
      entries
      |> Enum.map(&"#{&1.date} #{&1.title}")
      |> Enum.join("\n")

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, formatted_entries)
  end

  def child_spec(_arg) do
    port = System.get_env("TODO_PORT") |> Integer.parse() |> then(fn {value, _} -> value end)
    IO.puts("Starting cowboy on port #{port}...")
    Plug.Adapters.Cowboy.child_spec(
      scheme: :http,
      options: [port: port],
      plug: __MODULE__
    )
  end
end
