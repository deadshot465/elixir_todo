defmodule ToDo.DatabaseWorker do
  use GenServer

  @spec start({String.t(), integer()}) :: :ignore | {:error, any} | {:ok, pid}
  def start({folder, worker_id}) do
    GenServer.start(__MODULE__, [folder: folder], name: via_tuple(worker_id))
  end

  @spec start_link({String.t(), integer()}) :: :ignore | {:error, any} | {:ok, pid}
  def start_link({folder, worker_id}) do
    IO.puts("Starting database worker...")
    GenServer.start_link(__MODULE__, [folder: folder], name: via_tuple(worker_id))
  end

  @spec store(integer(), any, any) :: :ok
  def store(worker_id, key, data), do: GenServer.cast(via_tuple(worker_id), {:store, key, data})

  @spec get(integer(), any) :: any
  def get(worker_id, key), do: GenServer.call(via_tuple(worker_id), {:get, key})

  # Server Callbacks

  @impl GenServer
  @spec init([{:folder, any}, ...]) :: {:ok, {any}}
  def init([folder: folder]) do
    {:ok, {folder}}
  end

  @impl GenServer
  def handle_cast({:store, key, data}, {folder} = state) do
    spawn(fn ->
      key
      |> file_name(folder)
      |> File.write!(:erlang.term_to_binary(data))
    end)
    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:get, key}, from, {folder} = state) do
    spawn(fn ->
      data = case File.read(file_name(key, folder)) do
        {:ok, content} -> :erlang.binary_to_term(content)
        _ -> nil
      end
      GenServer.reply(from, data)
    end)

    {:noreply, state}
  end

  defp file_name(key, folder) do
    Path.join(folder, to_string(key))
  end

  defp via_tuple(worker_id) do
    ToDo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end
end
