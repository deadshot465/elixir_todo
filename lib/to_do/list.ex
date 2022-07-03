defmodule ToDo.List do
  defstruct auto_id: 1, entries: %{}

  @type t :: %__MODULE__{
          auto_id: integer(),
          entries: map()
        }

  @spec new :: ToDo.List.t()
  def new, do: %__MODULE__{}

  @spec add_entry(map, atom | %{:date => any, optional(any) => any}) :: map
  def add_entry(%__MODULE__{entries: entries, auto_id: id} = todo_list, entry) do
    entry = Map.put(entry, :id, id)
    new_entries = Map.put(entries, id, entry)
    %__MODULE__{todo_list | entries: new_entries, auto_id: id + 1}
  end

  @spec delete_entry(ToDo.List.t(), any) :: ToDo.List.t()
  def delete_entry(%__MODULE__{entries: entries} = todo_list, entry_id) do
    new_entries = Map.delete(entries, entry_id)
    %__MODULE__{todo_list | entries: new_entries}
  end

  @spec update_entry(ToDo.List.t(), %{:id => any, optional(any) => any}) ::
          ToDo.List.t()
  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  @spec update_entry(ToDo.List.t(), any, any) :: ToDo.List.t()
  def update_entry(%__MODULE__{entries: entries} = todo_list, entry_id, updater_fun) do
    case Map.fetch(entries, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(new_entry, new_entry.id, new_entry)
        %__MODULE__{todo_list | entries: new_entries}
    end
  end

  @spec entries(ToDo.List.t()) :: list
  def entries(%__MODULE__{entries: entries}) do
    entries |> Enum.map(fn {_, entry} -> entry end)
  end

  @spec entries(map, any) :: any
  def entries(%__MODULE__{entries: entries}, date) do
    entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end
end
