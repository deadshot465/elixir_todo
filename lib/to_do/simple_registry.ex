defmodule ToDo.SimpleRegistry do
  use GenServer

  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec whereis(any) :: any
  def whereis(key) do
    case :ets.lookup(:simple_registry, key) do
      [{^key, value}] -> value
      _ -> nil
    end
  end

  @spec register(any) :: :error | :ok
  def register(key) do
    Process.link(Process.whereis(__MODULE__))
    if :ets.insert_new(:simple_registry, {key, self()}) do
      :ok
    else
      :error
    end
  end

  # Server Callbacks

  @impl GenServer
  @spec init(any) :: {:ok, nil}
  def init(_init_arg) do
    Process.flag(:trap_exit, true)
    :ets.new(:simple_registry, [:named_table, :public, read_concurrency: true, write_concurrency: true])
    {:ok, nil}
  end

  @impl GenServer
  def handle_info({:EXIT, pid, _reason}, state) do
    :ets.match_delete(:simple_registry, {:_, pid})
    {:noreply, state}
  end
end
