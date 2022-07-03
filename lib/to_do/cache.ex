defmodule ToDo.Cache do
  use GenServer

  @spec start :: :ignore | {:error, any} | {:ok, pid}
  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @spec start_link(any()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    IO.puts("Starting To-Do cache...")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @spec server_process(any) :: any
  def server_process(todo_list_name), do: GenServer.call(__MODULE__, {:server_process, todo_list_name})

  @impl GenServer
  @spec init(any) :: {:ok, %{}}
  def init(_) do
    ToDo.Database.start_link()
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:server_process, todo_list_name}, _, servers) do
    case Map.fetch(servers, todo_list_name) do
      {:ok, todo_server} -> {:reply, todo_server, servers}
      :error ->
        new_server = ToDo.Server.start_link(todo_list_name)
        {:reply, new_server, Map.put(servers, todo_list_name, new_server)}
    end
  end


end
