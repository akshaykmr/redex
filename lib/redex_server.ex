defmodule Redex.Server do
  @moduledoc """
  A naive redis-server
  """

  @doc """
  starts the redis server

  ## Examples

      iex> Redex.Server.start_link()
      {:ok, #PID<0.102.0>}

  """
  def start_link do
    {:ok, self()}
  end
end
