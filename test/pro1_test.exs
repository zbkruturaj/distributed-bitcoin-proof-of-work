defmodule Pro1Test do
  use ExUnit.Case
  doctest Pro1

  test "greets the world" do
    assert Pro1.hello() == :world
  end
end
