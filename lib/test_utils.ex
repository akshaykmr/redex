defmodule Redex.TestUtils do
  def wait_for_server(retries \\ 5) do
    case :gen_tcp.connect('localhost', 6379, []) do
      {:ok, socket} ->
        :gen_tcp.close(socket)
      {:error, reason} ->
        cond do
          retries > 0 ->
            :timer.sleep(100)
            wait_for_server(retries - 1)
          :true ->
            Mix.raise "Cannot connect to Redis" <>
                  " (http://localhost:6379):" <>
                  " #{:inet.format_error(reason)}"
        end
    end
  end
end
