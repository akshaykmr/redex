defmodule Redex.Server do
  require Logger
  @moduledoc """
  little redis-server
  """

  @doc """
  starts the redis server

  ## Examples

      iex> Redex.Server.start_link([])
      {:ok, #PID<0.102.0>}

  """
  def start_link args do
    Task.start_link(fn -> Redex.Server.accept(args) end)
  end

  def accept(args) do
    # The options below mean:
    #
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes
    #
    port = Keyword.get(args, :port, 6379)
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Logger.debug "new client"

    # TODO: should use a supervisor here
    Task.start(fn -> handle_client(client) end)
    loop_acceptor(socket)
  end

  defp close_connection(socket, reason) do
    :gen_tcp.close(socket)
    Logger.debug "connection closed: #{reason}"
  end

  defp handle_client(socket, resume \\ nil) do
    case socket |> read_line()  do
      {:ok, line} ->
        try do
          line = String.trim(line)
          result = if resume == nil do Redex.RESPDecoder.read(line) else resume.(line) end

          if is_function(result) do
            handle_client(socket, result)
          else
            result |> Redex.Command.execute |> write_line(socket)
            handle_client(socket)
          end
        rescue
          e in RuntimeError -> close_connection(socket, e.message)
        end
      {:error, error} -> close_connection(socket, error)
    end
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
