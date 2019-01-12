defmodule RedexServerTest do
  use ExUnit.Case
  # doctest Redex.Server

  setup do
    IO.puts "starting server"
    {:ok, server} = Redex.Server.start_link([])
    %{pid: server}
  end

  setup context do
    Redex.TestUtils.wait_for_server()
    context
  end

  test "it starts", %{pid: pid} do
    assert Process.alive?(pid)
  end

  test "it responds to ping", %{pid: pid} do

  end
end


# defmodule AssertionTest do
#   use ExUnit.Case, async: true

#   # "setup_all" is called once per module before any test runs
#   setup_all do
#     IO.puts "Starting AssertionTest"

#     # Context is not updated here
#     :ok
#   end

#   # "setup" is called before each test
#   setup do
#     IO.puts "This is a setup callback for #{inspect self()}"

#     on_exit fn ->
#       IO.puts "This is invoked once the test is done. Process: #{inspect self()}"
#     end

#     # Returns extra metadata to be merged into context
#     [hello: "world"]

#     # Similarly, any of the following would work:
#     #   {:ok, [hello: "world"]}
#     #   %{hello: "world"}
#     #   {:ok, %{hello: "world"}}
#   end

#   # Same as above, but receives the context as argument
#   setup context do
#     IO.puts "Setting up: #{context.test}"
#     :ok
#   end

#   # Setups can also invoke a local or imported function that returns a context
#   setup :invoke_local_or_imported_function

#   test "always pass" do
#     assert true
#   end

#   test "uses metadata from setup", context do
#     assert context[:hello] == "world"
#     assert context[:from_named_setup] == true
#   end

#   defp invoke_local_or_imported_function(context) do
#     [from_named_setup: true]
#   end
# end
