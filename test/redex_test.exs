defmodule RedexTest do
  use ExUnit.Case
  doctest Redex

  test "greets the world" do
    assert Redex.hello() == :world
  end
end
