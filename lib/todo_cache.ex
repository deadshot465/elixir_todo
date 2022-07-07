defmodule TodoCache do
  use Application

  @impl Application
  @spec start(any, any) :: {:error, any} | {:ok, pid}
  def start(_, _) do
    ToDo.System.start_link()
  end
end
