defmodule TodoCacheTest do
  use ExUnit.Case
  doctest TodoCache

  test "server_process" do
    {:ok, cache} = ToDo.Cache.start()
    bob_pid = ToDo.Cache.server_process(cache, "Bob")

    assert bob_pid != ToDo.Cache.server_process(cache, "Amy")
    assert bob_pid == ToDo.Cache.server_process(cache, "Bob")
  end

  test "todo_operations" do
    {:ok, cache} = ToDo.Cache.start()
    tetsu_pid = ToDo.Cache.server_process(cache, "Tetsu")
    ToDo.Server.add_entry(tetsu_pid, %{date: ~D(2022-07-03), title: "Mom's Birthday"})
    entries = ToDo.Server.list_entries(tetsu_pid)
    assert [%{date: ~D(2022-07-03), title: "Mom's Birthday"}] = entries
  end
end
