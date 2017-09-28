defmodule GServer do
  use GenServer

  def init(state) do
    {:ok,state}
  end

  # Called when client connects to server
  def handle_call(:get_more, from, [k, state]) do
    IO.puts "Client asking for more work."
    {:reply, [k, (state-1)*16000000, 1000000], [k, state+1]}
  end

  # Called when client sends something to server
  def handle_cast({:printcoin, list}, state) do
    list
      |> Enum.map(fn({a,b}) -> IO.puts "#{a} #{b}" end)
    {:noreply, state}
  end



end
