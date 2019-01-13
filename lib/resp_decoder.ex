defmodule Redex.RESPDecoder do
  @moduledoc """
  Decodes incoming binary lines into array as per RESP (REdis Serialization Protocol)
  """

  @decode_error_message "RESP decode error"

  def read(start) do
    parse_line(start, &(&1))
  end


  def parse_int!(str) do
    {int, _} = Integer.parse(str)
    int
  end

  defp parse_line(line, callback) do
    case line do
      "+" <> str -> callback.(str)

      "$" <> len -> fn str -> parse_bulk_string(parse_int!(len), str, callback) end

      "*" <> len -> array_parser(parse_int!(len), callback)

      ":" <> str -> callback.(parse_int!(str))

      _ -> raise @decode_error_message
    end
  end

  defp parse_bulk_string(len, str, callback) do
    cond do
      str == "-1" -> callback.(nil)
      byte_size(str) == len -> callback.(str)
      :true -> raise @decode_error_message
    end
  end

  defp array_parser(len, callback, accumulator \\ []) do
    if length(accumulator) == len do
      callback.(accumulator)
    else
      fn line ->
        parse_line(
          line,
          fn result ->
            if is_function(result) do
              fn l -> result.(l, fn r -> array_parser(len, callback, accumulator ++ [r]) end) end
            else
              array_parser(len, callback, accumulator ++ [result])
            end
          end
        )
      end
    end
  end
end

