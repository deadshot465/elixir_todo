defmodule ToDo.Multidict do
  @spec new :: %{}
  def new, do: %{}

  @spec add(map, any, any) :: map
  def add(dict, key, value) do
    Map.update(dict, key, [value], &[value | &1])
  end

  @spec get(map, any) :: any
  def get(dict, key) do
    Map.get(dict, key, [])
  end
end
