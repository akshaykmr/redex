defmodule Redex.Command do
  import Redex.RESPEncoder
  @invalid_command_message "Command invalid or not implemented"


  def execute([command | args]) do
    case command |> String.upcase do
      "COMMAND" -> encode({:simple_str, "OK"})
      "PING" -> encode({:simple_str, "PONG"})
      "ECHO" -> encode({:simple_str, Enum.at(args, 0)})
      _ ->
          IO.inspect [command] ++ args
        raise @invalid_command_message
    end
  end
end

