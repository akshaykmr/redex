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

  test "set and get", %{conn: conn} do
    assert Redix.command!(conn, ["SET", "mykey", "somevalue"]) == "OK"
    assert Redix.command!(conn, ["GET", "mykey"]) == "somevalue"
  end

  test "set and get when expiry in seconds", %{conn: conn} do
    assert Redix.command!(conn, ["SET", "mykey", "somevalue", "ex", "1"]) == "OK"
    assert Redix.command!(conn, ["GET", "mykey"]) == "somevalue"
    # TODO: remove sleep
    :timer.sleep(1000)
    assert Redix.command!(conn, ["GET", "mykey"]) == nil
  end

  test "set and get when expiry in milliseconds", %{conn: conn} do
    assert Redix.command!(conn, ["SET", "mykey", "somevalue", "px", "10"]) == "OK"
    assert Redix.command!(conn, ["GET", "mykey"]) == "somevalue"
    :timer.sleep(10)
    assert Redix.command!(conn, ["GET", "mykey"]) == nil
  end
end
