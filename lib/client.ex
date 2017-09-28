defmodule Client do
  use GenServer

  def hi(pid) do
      [k, start, batch_size]  = GenServer.call(pid, :get_more)
      IO.puts "k is #{k}, batch_size is #{batch_size}, starting from #{start}"

      1..16
        |> Enum.map(fn (x) -> spawn(Project1, :worker_main_client, [])
                                |> send({:get_coin, pid, k, start+(x-1)*1000000, 1000000})
                                end)
    end

    def printcoin(pid, k) do
      GenServer.cast(pid, {:printcoin, k})
      hi(pid)
    end
end
