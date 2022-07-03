defmodule ToDo.DatabaseWorker do
  use GenServer

  @spec start(any) :: :ignore | {:error, any} | {:ok, pid}
  def start(folder) do
    GenServer.start(__MODULE__, [folder: folder])
  end

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(folder) do
    IO.puts("Starting database worker...")
    GenServer.start_link(__MODULE__, [folder: folder])
  end

  @spec store(atom | pid | {atom, any} | {:via, atom, any}, any, any) :: :ok
  def store(pid, key, data), do: GenServer.cast(pid, {:store, key, data})

  @spec get(atom | pid | {atom, any} | {:via, atom, any}, any) :: any
  def get(pid, key), do: GenServer.call(pid, {:get, key})

  # Server Callbacks

  @impl GenServer
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
end
