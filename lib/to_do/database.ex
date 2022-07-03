defmodule ToDo.Database do
  @pool_size 3
  @db_folder "./persist"

  @spec start_link() :: :ignore | {:error, any} | {:ok, pid}
  def start_link do
    IO.puts("Starting database server supervisor...")

    File.mkdir_p!(@db_folder)
    children = Enum.map(1..@pool_size, &worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @spec store(any, any) :: :ok
  def store(key, data) do
    key |> choose_worker() |> ToDo.DatabaseWorker.store(key, data)
  end

  @spec get(any) :: any
  def get(key) do
    key |> choose_worker() |> ToDo.DatabaseWorker.get(key)
  end

  # Internal functions

  defp worker_spec(worker_id) do
    default_worker_spec = {ToDo.DatabaseWorker, {@db_folder, worker_id}}
    Supervisor.child_spec(default_worker_spec, id: worker_id)
  end

  # Server Callbacks

  @spec child_spec(any) :: %{
          id: ToDo.Database,
          start: {ToDo.Database, :start_link, []},
          type: :supervisor
        }
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end
end
