defmodule ToDo.Server do
  use Agent, restart: :temporary

  # Interfaces

  @spec start(any) :: :ignore | {:error, any} | {:ok, pid}
  def start(todo_list_name) do
    Agent.start(fn ->
      IO.puts("Starting server for #{todo_list_name}...")
      {todo_list_name, ToDo.Database.get(todo_list_name) || ToDo.List.new()}
    end, name: global_name(todo_list_name))
  end

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(todo_list_name) do
    Agent.start_link(fn ->
      IO.puts("Starting server for #{todo_list_name}...")
      {todo_list_name, ToDo.Database.get(todo_list_name) || ToDo.List.new()}
    end, name: global_name(todo_list_name))
  end

  @spec add_entry(atom | pid | {atom, any} | {:via, atom, any}, any) :: :ok
  def add_entry(pid, entry) do
    Agent.cast(pid, fn {name, state} ->
      new_state = ToDo.List.add_entry(state, entry)
      ToDo.Database.store(name, new_state)
      {name, new_state}
    end)
  end

  @spec list_entries(atom | pid | {atom, any} | {:via, atom, any}) :: any
  def list_entries(pid) do
    Agent.get(pid, fn {_, state} ->
      ToDo.List.entries(state)
    end)
  end

  @spec list_entries(atom | pid | {atom, any} | {:via, atom, any}, any) :: any
  def list_entries(pid, date) do
    Agent.get(pid, fn {_, state} ->
      ToDo.List.entries(state, date)
    end)
  end

  @spec whereis(any) :: nil | pid
  def whereis(todo_list_name) do
    case :global.whereis_name({__MODULE__, todo_list_name}) do
      :undefined -> nil
      pid -> pid
    end
  end

  # Internal functions

  defp global_name(todo_list_name) do
    {:global, {__MODULE__, todo_list_name}}
  end
end
