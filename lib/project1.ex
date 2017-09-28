defmodule Project1 do
  @moduledoc """
  Documentation for Pro1.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Pro1.hello
      :world

  """
  def main(args \\ []) do
    [arg|tail] = args
    arg |> branch
    do_not_exit
  end

  def branch(arg) do
    case String.contains? arg, "." do
      true -> arg
                |> String.to_atom
                |> client_main
      false -> arg
                |> Integer.parse
                |> first
                |> server_main
    end
  end

  defp first({i, s}) do
    i
  end

  defp parse_args(args) do
      {opts, word, _} = args
      word
  end

  def client_main(server_ip) do
    IO.puts "On Client, connecting to #{server_ip}...."
    {_, ips} = :inet.getif()
    {a,b,c,d} = ips
                |> Enum.map(fn {a,_,_} -> a end)
                |> Enum.filter(fn {a,_,_,_} -> a != 127 end)
                |> List.last
    (gen_random_string <> "@#{a}.#{b}.#{c}.#{d}")
      |> String.to_atom
      |>  Node.start
    Node.set_cookie(Node.self(), :netten)
    case Node.connect(:"a@#{server_ip}") do
      true -> :ok
      reason ->
        IO.puts "Could not connect to server, reason: #{reason}"
        System.halt(0)
    end
    :global.sync()
    :global.registered_names
    pid = :global.whereis_name(:server)
    spawn_link(Client, :hi, [pid])
  end

  def server_main(k) do
    IO.puts "On Server, k is #{k}"
    {_, ips} = :inet.getif()
    {a,b,c,d} = ips
                |> Enum.map(fn {a,_,_} -> a end)
                |> Enum.filter(fn {a,_,_,_} -> a != 127 end)
                |> List.last
    {status, node_pid} = :"a@#{a}.#{b}.#{c}.#{d}"
      |> Node.start
    Node.set_cookie(Node.self(), :netten)
    IO.puts status
    {:ok, server_pid} = GenServer.start_link(GServer, [k, 1])
    :global.sync()
    :global.register_name(:server, server_pid)
    1..16
      |> Enum.map(fn (x) -> spawn(Project1, :worker_main_server, [])
                              |> send({:get_coin, k, (x-1)*1000000, 1000000})
                              end)
  end

  defp seed_random do
    use_monotonic = :erlang.module_info
        |> Keyword.get( :exports )
        |> Keyword.get( :monotonic_time )
    time_bif = case use_monotonic do
      1   -> &:erlang.monotonic_time/0
      nil -> &:erlang.now/0
    end
    :random.seed( time_bif.() )
  end

  def gen_random_string( length \\ 12) do
    seed_random
      alphabet
          =  "abcdefghijklmnopqrstuvwxyz"
          <> "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
          <> "0123456789"
      alphabet_length =

      alphabet |> String.length

      1..length
        |> Enum.map_join(
          fn(_) ->
            alphabet |> String.at( :random.uniform( alphabet_length ) - 1 )
          end
        )
  end

  def worker_main_server() do
      receive do
        {:get_coin, k, start, batch_size} -> work_server(k, start, batch_size)
      end
  end

  def work_server(k, start, batch_size) do
    find_coin_server(k, start, start+batch_size)
                          |> Enum.map(fn({a,b}) -> IO.puts "#{a} #{b}" end)
    work_server(k, start+batch_size*16, batch_size)
  end

  def find_coin_server(k, start, stop, state \\ []) do
      zero = gen_zero_string(k)
      coin = "zadbuke.ruturaj;server_#{start}"
      hash = Base.encode16(:crypto.hash(:sha256, coin))
      case String.starts_with?(hash, zero) do
        true ->  new_state = [{coin, hash}|state]
        false -> new_state = state
      end
      if start != stop do
        find_coin_server(k, start+1, stop, new_state)
      else
        new_state
      end
  end

  def worker_main_client() do
      receive do
        {:get_coin, pid, k, start, batch_size} -> work_client(pid, k, start, batch_size)
      end
  end

  def work_client(pid, k, start, batch_size) do
    coins = find_coin_client(k, start, start+batch_size)
    Client.printcoin(pid, coins)
  end

  def find_coin_client(k, start, stop, state \\ []) do
      zero = gen_zero_string(k)
      coin = "zadbuke.ruturaj;client_#{start}"
      hash = Base.encode16(:crypto.hash(:sha256, coin))
      case String.starts_with?(hash, zero) do
        true ->  new_state = [{coin, hash}|state]
        false -> new_state = state
      end
      if start != stop do
        find_coin_client(k, start+1, stop, new_state)
      else
        new_state
      end
  end


  def gen_zero_string(k) do
    1..k
    |> Enum.map_join(
      fn(_) ->
        "0"
      end
      )
  end

  def do_not_exit do
      do_not_exit
  end
end
