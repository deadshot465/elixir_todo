defmodule ToDo.Cache do
  @spec start_link(any()) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(_) do
    IO.puts("Starting To-Do cache...")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  @spec server_process(any) :: any
  def server_process(todo_list_name) do
    case start_child(todo_list_name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

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
