defmodule RedexServerTest do
  use ExUnit.Case

  @test_port 6455
  # doctest Redex.Server


  def get_connection do
    Redix.start_link(host: "localhost", port: @test_port)
  end

  setup do
    IO.puts "starting server"
    {:ok, server} = Redex.Server.start_link([port: @test_port])
    %{pid: server}
  end

  setup do
    Redex.TestUtils.wait_for_server("localhost", @test_port)
    :ok
  end

  setup do
    {:ok, conn} = get_connection()
    %{conn: conn}
  end

  test "it starts", %{pid: pid} do
    assert Process.alive?(pid)
  end

  test "it responds to ping", %{conn: conn} do
    assert Redix.command!(conn, ["PING"]) == "PONG"
  end

  test "it can handle multiple clients", %{conn: conn} do
    assert Redix.command!(conn, ["PING"]) == "PONG"
    {:ok, conn2} = get_connection()
    assert Redix.command!(conn2, ["PING"]) == "PONG"
  end

  test "it can handle mutiple commands from same client", %{conn: conn} do
    assert Redix.command!(conn, ["PING"]) == "PONG"
    assert Redix.command!(conn, ["PING"]) == "PONG"
  end

  test "echo command", %{conn: conn} do
    assert Redix.command!(conn, ["ECHO", "HEY!"]) == "HEY!"
  end

  test "set and get command", %{conn: conn} do
    assert Redix.command!(conn, ["SET", "mykey", "somevalue"]) == "OK"
    assert Redix.command!(conn, ["GET", "mykey"]) == "somevalue"
  end
end
