defmodule Geolix.Database.Loader do
  @moduledoc """
  Takes care of (re-) loading databases.
  """

  use GenServer

  # GenServer lifecycle

  @doc """
  Starts the database loader.
  """
  @spec start_link(list) :: GenServer.on_start
  def start_link(databases \\ []) do
    GenServer.start_link(__MODULE__, databases, name: __MODULE__)
  end

  def init(databases) do
    init_databases(databases)

    state =
      databases
      |> Enum.map(&fix_legacy/1)
      |> Enum.map(fn (database) -> { database[:id], database } end)

    { :ok, state }
  end


  # GenServer callbacks

  def handle_call({ :get_database, which }, _, state) do
    { :reply, state[which], state }
  end

  def handle_call({ :load_database, database }, _, state) do
    case load_database(database) do
      :ok   -> { :reply, :ok, Keyword.put(state, database[:id], database) }
      error -> { :reply, error, state }
    end
  end

  def handle_call({ :set_database, which, filename }, from, state) do
    database = fix_legacy({ which, filename })

    handle_call({ :load_database, database }, from, state)
  end

  def handle_call(:registered, _, state) do
    { :reply, Keyword.keys(state), state }
  end


  # Internal methods

  defp fix_legacy(database) when is_map(database), do: database
  defp fix_legacy({ which, filename }) do
    IO.write :stderr, "The database '#{ inspect which }' is loaded using" <>
                      " a deprecated tuple definition. Please update to" <>
                      " the new map based format."

    %{
      id:      which,
      adapter: Geolix.Adapter.MMDB2,
      source:  filename
    }
  end


  defp init_databases([]), do: []
  defp init_databases([ database | databases ]) do
    database
    |> fix_legacy()
    |> load_database()

    init_databases(databases)
  end

  defp load_database(%{ source: { :system, var }} = database) do
    database
    |> Map.put(:source, System.get_env(var))
    |> load_database()
  end

  defp load_database(%{ adapter: adapter } = database) do
    adapter.load_database(database)
  end
end
