# Project1
by Ruturaj Zadbuke (UFID:66726959)

The project uses Elixir's actor modeling to implement concurrency. The same executable acts as both server and client. Genserver is used for communication over TCP/IP within the network.

1. First, the server is started. It starts the genServer and one of its process starts listening for clients. Its other processes meanwhile continue to mine for bitcoins of the format "zadbuke.ruturaj;server_#{x}". Each process recieves a k, a batch_size and a starting point, these latter two parameters are used to calculate x and the k is used to verify coins. At the end of each batch all the coins are printed.The server has 16 mining workers at a time.

When the client connects to the server, it recieves a k, a batch_size for individual processes and a starting point. The client also launches 16 workers for mining and each workers gets a batch_size worth of data. The k is used to verify. When mining a batch is done, that part is sent back to the server and the server then prints the mined coins.

Batch_size or work_unit size is 1 million.

2.  For k = 5
    real time is  4m43.723s = 283.723s
    cpu_time  is 17m54.508s = 1074.508s
    Ratio = 3.78

    For k = 4
    real time is  4m01.093s = 241.093s
    cpu_time  is 15m10.812s = 910.812s
    Ratio = 3.77

3. The coin with maximum 0s was zadbuke.ruturaj;server_1952345
    whose hash 000000E7113244726612024801E3A1F23A415410B5EDD6ABA02413BCB1A4B560
    had 6 zeros.

4. While I do believe that the number of machines shouldn't have an upper_limit since we are using randomized node naming, I was able to run the code on two machines at max. Since, I had access to only 2.
