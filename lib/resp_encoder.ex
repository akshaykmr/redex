defmodule Redex.RESPEncoder do
  @crlf "\r\n"

  def encode(data) when is_list(data), do: "*#{Enum.count(data)}#{@crlf}" <> encode_array(data, "")
  def encode({:simple_str, value}), do: "+#{value}#{@crlf}"
  def encode({:error_str, value}), do: "-#{value}#{@crlf}"
  def encode({:integer, value}), do: ":#{value}#{@crlf}"
  def encode({:bulk_str, nil}), do: "$-1#{@crlf}"
  def encode({:bulk_str, value}), do: "$#{String.length(value)}#{@crlf}#{value}#{@crlf}"
  def encode(_), do: raise "Unable to encode response"

  defp encode_array([head | tail], accumulator), do: encode_array(tail, accumulator <> encode(head))
  defp encode_array([], accumulator), do: accumulator
end
