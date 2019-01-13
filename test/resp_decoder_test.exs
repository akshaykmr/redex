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
    assert parse_line("$4", &(&1)).("Blah") == "Blah"
  end

  test "it raises error for invalid protocol" do
    assert_raise(RuntimeError, fn -> parse_line("sf23r") end)
  end

  test "it can read 0 element array" do
    assert parse_line("*0", &(&1)) == []
  end

  test "it can read 1 element array" do
    assert parse_line("*1", &(&1)).(":4") == [4]
  end

  test "it can read n element array" do
    assert parse_line("*3", &(&1)).(":90").(":11").(":124") == [90, 11, 124]
  end

  test "it can read array of bulk strings" do
    assert parse_line("*2", &(&1)).("$4").("It's").("$8").("Working!") == ["It's", "Working!"]
  end

  test "it can read mixed n element array" do
    result = parse_line("*5", &(&1))
              .(":42")
              .("+The")
              .("$6")
              .("answer")
              .("+to")
              .("$4")
              .("life")
    assert result == [42, "The", "answer", "to", "life"]
  end

  test "it can read nested arrays" do
    result = parse_line("*2", &(&1))
              .("*2")
              .("+Mojo")
              .("+Jojo")
              .("*2")
              .("+Professor")
              .("+X")
    assert result  == [["Mojo", "Jojo"], ["Professor", "X"]]
  end
end
