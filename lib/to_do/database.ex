defmodule ToDo.Database do
  @db_folder "./persist"

  @spec store(any, any) :: :ok
  def store(key, data) do
    :poolboy.transaction(__MODULE__,
    fn worker_pid -> ToDo.DatabaseWorker.store(worker_pid, key, data) end)
  end

  @spec get(any) :: any
  def get(key) do
    :poolboy.transaction(__MODULE__,
    fn worker_pid -> ToDo.DatabaseWorker.get(worker_pid, key) end)
  end

  # Internal functions

  def child_spec(_) do
    IO.puts("Starting database pool...")
    File.mkdir_p!(@db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: ToDo.DatabaseWorker,
        size: 3
      ],
      [@db_folder]
    )
  end
end
