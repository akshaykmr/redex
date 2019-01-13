defmodule RESPDecoderTest do
  use ExUnit.Case
  import Redex.RESPDecoder

  test "it can read simple string" do
    assert read("+hey") == "hey"
  end

  test "it can read integer" do
    assert read(":1337") == 1337
  end

  test "interger parse util" do
    assert parse_int!("124") == 124
  end

  test "it can read bulk string" do
    assert read("$4").("Blah") == "Blah"
  end

  test "it raises error for invalid protocol" do
    assert_raise(RuntimeError, fn -> read("sf23r") end)
  end

  test "it can read 0 element array" do
    assert read("*0") == []
  end

  test "it can read 1 element array" do
    assert read("*1").(":4") == [4]
  end

  test "it can read n element array" do
    assert read("*3").(":90").(":11").(":124") == [90, 11, 124]
  end

  test "it can read array of bulk strings" do
    assert read("*2").("$4").("It's").("$8").("Working!") == ["It's", "Working!"]
  end

  test "it can read mixed n element array" do
    result = read("*5")
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
    result = read("*2")
              .("*2")
              .("+Mojo")
              .("+Jojo")
              .("*2")
              .("+Professor")
              .("+X")
    assert result  == [["Mojo", "Jojo"], ["Professor", "X"]]
  end
end
