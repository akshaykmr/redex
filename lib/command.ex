defmodule Redex.Command do
  @crlf "\r\n"
  @invalid_command_message "Command invalid or not implemented"


  def execute([command | _args]) do
    case command |> String.upcase do
      "COMMAND" -> "+OK" <> @crlf
      "PING" -> "+PONG" <> @crlf
      _ -> raise @invalid_command_message
    end
  end
end

