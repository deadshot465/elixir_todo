defmodule ToDo.Database do
  @db_folder "./persist"

  @spec store(any, any) :: :ok
  def store(key, data) do
    {_results, bad_nodes} = :rpc.multicall(__MODULE__, :store_local, [key, data], :timer.seconds(5))

    Enum.each(bad_nodes, &IO.puts("Store failed on node #{&1}"))
    :ok
  end

  @spec store_local(any, any) :: :ok
  def store_local(key, data) do
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
    node_identifier = node() |> Atom.to_string() |> String.split("@") |> hd()
    folder_name = @db_folder <> "/" <> node_identifier
    IO.puts("Starting database pool...")
    File.mkdir_p!(folder_name)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: ToDo.DatabaseWorker,
        size: 3
      ],
      [folder_name]
    )
  end
end
