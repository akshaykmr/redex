defmodule Redex.TestUtils do

  def wait_for_server(host, port, retries \\ 5) when is_binary(host) do
    wait(to_charlist(host), port, retries)
  end

  defp wait(host, port, retries) do
    case :gen_tcp.connect(host, port, []) do
      {:ok, socket} ->
        :gen_tcp.close(socket)
      {:error, reason} ->
        cond do
          retries > 0 ->
            :timer.sleep(100)
            wait(host, port, retries - 1)
          :true ->
            Mix.raise "Cannot connect to server" <>
                  " (#{host}:#{port}):" <>
                  " #{:inet.format_error(reason)}"
        end
    end
  end
end
