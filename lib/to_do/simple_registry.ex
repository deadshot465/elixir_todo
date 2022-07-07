defmodule ToDo.SimpleRegistry do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def whereis(key), do: GenServer.call(__MODULE__, {:whereis, key})

  def register(key), do: GenServer.call(__MODULE__, {:register, key})

  # Server Callbacks

  @impl GenServer
  @spec init(any) :: {:ok, atom | :ets.tid()}
  def init(_init_arg) do
    {:ok, :ets.new(:simple_registry, [:named_table, {:read_concurrency, true}])}
  end

  @impl GenServer
  def handle_call({:whereis, key}, _from, state) do
    case :ets.lookup(state, key) do
      [{^key, value}] -> {:reply, value, state}
      _ -> {:reply, nil, state}
    end
  end

  @impl GenServer
  def handle_call({:register, key}, _from, state) do
    case :ets.insert_new(state, key) do
      true -> {:reply, :ok, state}
      _ -> {:reply, :error, state}
    end
  end
end
