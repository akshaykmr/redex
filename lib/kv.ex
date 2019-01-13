defmodule Redex.KV do
  @moduledoc """
  in memory key value store, using Agent
  """
  use Agent
  require Logger

  @default_state %{}

  def start_link(args \\ []) do
    Agent.start_link(fn -> Keyword.get(args, :state, @default_state) end, name: __MODULE__)
  end

  def get(key) do
    Agent.get(__MODULE__, &(Map.get(&1, key)))
  end

  def set(key, value) do
    Agent.update(__MODULE__, &(Map.put(&1, key, value)))
  end
end
