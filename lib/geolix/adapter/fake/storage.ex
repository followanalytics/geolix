defmodule Geolix.Adapter.Fake.Storage do
  @moduledoc false

  use Agent

  @doc false
  @spec start_link(map) :: Agent.on_start()
  def start_link(initial_value \\ %{}) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  @doc """
  Fetches the data for a database.
  """
  @spec get(atom) :: map | nil
  def get(database) do
    Agent.get(__MODULE__, &Map.get(&1, database, %{}))
  end

  @doc """
  Stores the data for a specific database.
  """
  @spec set(atom, term) :: :ok
  def set(database, data) do
    Agent.update(__MODULE__, &Map.put(&1, database, data))
  end
end
