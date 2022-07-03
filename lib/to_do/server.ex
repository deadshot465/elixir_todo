defmodule ToDo.Server do
  use GenServer

  # Interfaces

  @spec start(any()) :: pid
  def start(todo_list_name) do
    {:ok, pid} = GenServer.start(__MODULE__, [name: todo_list_name])
    pid
  end

  @spec start_link(any) :: pid
  def start_link(todo_list_name) do
    IO.puts("Starting server for #{todo_list_name}...")
    {:ok, pid} = GenServer.start_link(__MODULE__, [name: todo_list_name])
    pid
  end

  @spec add_entry(atom | pid | {atom, any} | {:via, atom, any}, any) :: :ok
  def add_entry(pid, entry), do: GenServer.cast(pid, {:add, entry})

  @spec list_entries(atom | pid | {atom, any} | {:via, atom, any}) :: any
  def list_entries(pid), do: GenServer.call(pid, :entries)

  @spec list_entries(atom | pid | {atom, any} | {:via, atom, any}, any) :: any
  def list_entries(pid, date), do: GenServer.call(pid, {:entries, date})

  # Serve Callbacks

  @impl GenServer
  @spec init([{:name, any}, ...]) :: {:ok, nil}
  def init([name: todo_list_name]) do
    send(self(), {:real_init, todo_list_name})
    {:ok, nil}
  end

  @impl GenServer
  def handle_cast({:add, entry}, {name, state}) do
    new_state = ToDo.List.add_entry(state, entry)
    ToDo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  @impl GenServer
  def handle_call(:entries, _from, {_, state} = s) do
    {:reply, ToDo.List.entries(state), s}
  end

  @impl GenServer
  def handle_call({:entries, date}, _from, {_, state} = s) do
    entries = ToDo.List.entries(state, date)
    {:reply, entries, s}
  end

  @impl GenServer
  def handle_info({:real_init, todo_list_name}, _) do
    {:noreply, {todo_list_name, ToDo.Database.get(todo_list_name) || ToDo.List.new()}}
  end
end
