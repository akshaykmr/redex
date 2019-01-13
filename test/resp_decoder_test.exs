defmodule RESPDecoderTest do
  use ExUnit.Case
  import Redex.RESPDecoder

  test "it can parse simple string" do
    assert parse_line("+hey", &(&1)) == "hey"
  end

  test "it can parse integer" do
    assert parse_line(":1337", &(&1)) == 1337
  end

  test "interger parse util" do
    assert parse_int!("124") == 124
  end

  test "it can read bulk string" do
    next = parse_line("$4", &(&1))
    assert "Blah" == next.("Blah")
  end

  test "it raises error for invalid protocol" do
    assert_raise(RuntimeError, fn -> parse_line("sf23r") end)
  end

  test "it can read 0 element array" do
    assert parse_line("*0", &(&1)) == []
  end

  test "it can read 1 element array" do
    next = parse_line("*1", &(&1))
    assert next.(":4") == [4]
  end

  test "it can read n element array" do
    next = parse_line("*3", &(&1))
    next = next.(":90")
    next = next.(":11")
    assert next.(":124") == [90, 11, 124]
  end

  test "it can read array of bulk strings" do
    next = parse_line("*2", &(&1))
    next = next.("$4")
    next = next.("It's")
    next = next.("$8")
    assert next.("Working!") == ["It's", "Working!"]
  end
end
