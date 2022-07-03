defmodule ToDo.Database do
  use GenServer

  @db_folder "./persist"

  @spec start :: :ignore | {:error, any} | {:ok, pid}
  def start do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    IO.puts("Starting database server...")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @spec store(any, any) :: :ok
  def store(key, data) do
    worker_pid = GenServer.call(__MODULE__, {:choose_worker, key})
    ToDo.DatabaseWorker.store(worker_pid, key, data)
  end

  @spec get(any) :: any
  def get(key) do
    worker_pid = GenServer.call(__MODULE__, {:choose_worker, key})
    ToDo.DatabaseWorker.get(worker_pid, key)
  end

  # Server Callbacks

  @impl GenServer
  @spec init(any) :: {:ok, nil}
  def init(_) do
    File.mkdir_p!(@db_folder)
    worker_map = Enum.map(0..2, fn index ->
      {:ok, pid} = ToDo.DatabaseWorker.start_link(@db_folder)
      {index, pid}
    end) |> Enum.into(%{})

    {:ok, worker_map}
  end

  @impl GenServer
  def handle_cast(_, worker_map) do
    {:noreply, worker_map}
  end

  @impl GenServer
  def handle_call({:choose_worker, key}, _from, worker_map) do
    worker_pid = choose_worker(key, worker_map)
    {:reply, worker_pid, worker_map}
  end

  defp choose_worker(key, worker_map) do
    hash = :erlang.phash2(key, 3)
    worker_map[hash]
  end
end
