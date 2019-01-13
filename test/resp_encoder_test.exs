defmodule RESPEncoderTest do
  use ExUnit.Case
  import Redex.RESPEncoder

  test "it can encode simple string" do
    assert encode({:simple_str, "OK"}) == "+OK\r\n"
  end

end
