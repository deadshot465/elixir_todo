defmodule ToDo.Cache do
  @spec start_link() :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    IO.puts("Starting To-Do cache...")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  @spec server_process(any) :: any
  def server_process(todo_list_name) do
    case ToDo.Server.whereis(todo_list_name) do
      nil ->
        case start_child(todo_list_name) do
          {:ok, pid} -> pid
          {:error, {:already_started, pid}} -> pid
        end
      pid -> pid
    end
  end

  @spec child_spec(any) :: %{
          id: ToDo.Cache,
          start: {ToDo.Cache, :start_link, []},
          type: :supervisor
        }
  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  # Internal functions

  defp start_child(todo_list_name) do
    DynamicSupervisor.start_child(__MODULE__, {ToDo.Server, todo_list_name})
  end
end
