defmodule Redex.Command do
  import Redex.RESPEncoder
  @invalid_command_message "Command invalid or not implemented"


  def execute([command | args]) do
    case command |> String.upcase do
      "COMMAND" -> encode({:simple_str, "OK"})
      "PING" -> encode({:simple_str, "PONG"})
      "ECHO" -> encode({:simple_str, Enum.at(args, 0)})
      "SET" ->
        [key, value] = args
        Redex.KV.set(key, value)
        encode({:simple_str, "OK"})
      "GET" ->
        [key] = args
        encode({:bulk_str, Redex.KV.get(key)})
      _ ->
          IO.inspect [command] ++ args
        raise @invalid_command_message
    end
  end
end

