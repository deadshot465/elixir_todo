defmodule ToDo.System do
  @spec start_link :: {:error, any} | {:ok, pid}
  def start_link do
    Supervisor.start_link([
      ToDo.Database,
      ToDo.Cache,
      ToDo.Web
      ], strategy: :one_for_one)
  end
end
