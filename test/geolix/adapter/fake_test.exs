defmodule Geolix.Adapter.FakeTest do
  use ExUnit.Case, async: true

  doctest Geolix.Adapter.Fake

  test "fake adapter (loading) lifecycle" do
    ip = {42, 42, 42, 42}
    result = :fake_result
    lifecycle_id = :test_fake_adapter_lifecycle

    lifecycle_db = %{
      id: lifecycle_id,
      adapter: Geolix.Adapter.Fake,
      data: %{ip => result}
    }

    refute Geolix.lookup(ip, where: lifecycle_id)

    Geolix.load_database(lifecycle_db)

    assert result == Geolix.lookup(ip, where: lifecycle_id)

    Geolix.unload_database(lifecycle_id)

    refute Geolix.lookup(ip, where: lifecycle_id)
  end
end
