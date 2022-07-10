defmodule ToDo.DatabaseWorker do
  use GenServer

  @spec start({String.t(), integer()}) :: :ignore | {:error, any} | {:ok, pid}
  def start(folder) do
    GenServer.start(__MODULE__, [folder: folder])
  end

  @spec start_link({String.t(), integer()}) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(folder) do
    IO.puts("Starting database worker...")
    GenServer.start_link(__MODULE__, [folder: folder])
  end

  @spec store(pid(), any, any) :: :ok
  def store(worker_pid, key, data), do: GenServer.call(worker_pid, {:store, key, data})

  @spec get(pid(), any) :: any
  def get(worker_pid, key), do: GenServer.call(worker_pid, {:get, key})

  # Server Callbacks

  @impl GenServer
  @spec init([{:folder, any}, ...]) :: {:ok, {any}}
  def init([folder: folder]) do
    {:ok, {folder}}
  end

  @impl GenServer
  def handle_call({:store, key, data}, from, {folder} = state) do
    spawn(fn ->
      key
      |> file_name(folder)
      |> File.write!(:erlang.term_to_binary(data))
      GenServer.reply(from, :ok)
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
end
