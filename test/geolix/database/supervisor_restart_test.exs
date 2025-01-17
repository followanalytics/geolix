defmodule Geolix.Database.SupervisorRestartTest do
  use ExUnit.Case, async: false

  alias Geolix.Adapter.Fake
  alias Geolix.TestHelpers.DatabaseSupervisor

  @ip {55, 55, 55, 55}
  @result :fake_result
  @reload_id :test_reload
  @reload_db %{
    id: @reload_id,
    adapter: Fake,
    data: Map.put(%{}, @ip, @result)
  }

  setup do
    databases = Application.get_env(:geolix, :databases, [])

    :ok = Application.put_env(:geolix, :databases, [@reload_db])
    :ok = DatabaseSupervisor.restart()

    on_exit(fn ->
      :ok = Application.put_env(:geolix, :databases, databases)
      :ok = DatabaseSupervisor.restart()
    end)
  end

  test "reload databases on supervisor restart" do
    assert @result == Geolix.lookup(@ip, where: @reload_id)

    # break data
    Fake.Storage.set(@reload_id, %{})

    assert nil == Geolix.lookup(@ip, where: @reload_id)

    # reload to fix lookup
    :ok = DatabaseSupervisor.restart()

    assert @result == Geolix.lookup(@ip, where: @reload_id)
  end
end
