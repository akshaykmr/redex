# Redex

###  A naive redis-server implemented in Elixir

You can connect to this server using `redis-cli` and execute a few implemented commands like `get, set, setx`!
It talks in the Redis's [`RESP`](https://redis.io/topics/protocol) protocol and serves clients over TCP just like the real thing.

### How to run it?

- You must have [elixir installed](https://elixir-lang.org/install.html)
- In project root:
  1. `mix deps.get`
  2. `iex -S mix`
  3. `Redex.Server.start_link port: 6379`

- run tests with: mix test


### Code overview:

Here's the breakdown in brief:
- `redex_server.ex` -> TCP server. For each accepted socket, we start a `Task` to serve the client.
- `resp_decoder.ex` -> streaming resp parser. coverts bytes from the client to elixir data structures, in this case, command and args.
- `command.ex` -> execute the parsed redis command.
- `resp_encoder.ex` -> encode to resp duh, then send it to the client.
- `kv.ex` -> Simple kv state provided by Agent.

I think this is a cool place to play with Elixir, I come back to it when I need a refresher.
This project has a TCP server, binaries, parsing, state, and tests! You can follow the git history commit by commit.
Let me know if things can be done in a better way.

### Credits:

[Paul](https://rohitpaulk.com) - for hosting [Build your own Redis challenge!](https://rohitpaulk.com/articles/redis-challenge)
He has also written posts on how - [over here](https://rohitpaulk.com/articles/redis-0)

We did this challenge in Python. But I so-wanted to build this in Elixir, along with test-suite, so here it is. 


### Misc: Some benchmarks for fun!

Spoiler alert - it's not faster than the C server, duh. But I wanted to play around.

We only test for `GET` and `SET` commands, since those are the ones we've implemented (essentials that is, since we don't involve disk at all for things like persistence logs).

Tools used:
Redis version: 4
`redis-benchmark` comes installed with Redis. [Know more about redis-benchmark](https://redis.io/topics/benchmarks).

```
system specs:
Ryzen 3700x - 8 cores, 16 thread. liquid cooled 🧐
32GB ram
ubuntu 18.04
ulimit -n 65535 for the server processes. (the maximum number of open file descriptors)
```



```
- Simple test: 50 clients, 100000 requests

# Redis
➜  ~ redis-benchmark -t GET,SET -p 7000
====== SET ======
  100000 requests completed in 0.79 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

100.00% <= 0 milliseconds
126903.55 requests per second

====== GET ======
  100000 requests completed in 0.74 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

100.00% <= 1 milliseconds
100.00% <= 1 milliseconds
135501.36 requests per second

# Redex
➜  ~ redis-benchmark -t GET,SET -p 6000
====== SET ======
  100000 requests completed in 0.82 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.92% <= 1 milliseconds
99.97% <= 2 milliseconds
100.00% <= 3 milliseconds
100.00% <= 4 milliseconds
121802.68 requests per second

====== GET ======
  100000 requests completed in 0.81 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.97% <= 1 milliseconds
99.99% <= 2 milliseconds
100.00% <= 2 milliseconds
122850.12 requests per second

** about similar performance?
```

```
Let's increase requests by x10

# Redis 
➜  ~ redis-benchmark -t GET,SET -p 7000 -n 1000000
====== SET ======
  1000000 requests completed in 7.36 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

100.00% <= 1 milliseconds
100.00% <= 1 milliseconds
135888.03 requests per second

====== GET ======
  1000000 requests completed in 7.34 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

100.00% <= 1 milliseconds
100.00% <= 1 milliseconds
136147.05 requests per second


# Redex
➜  ~ redis-benchmark -t GET,SET -p 6000 -n 1000000
====== SET ======
  1000000 requests completed in 8.35 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.74% <= 1 milliseconds
99.91% <= 2 milliseconds
99.96% <= 3 milliseconds
99.98% <= 4 milliseconds
99.99% <= 5 milliseconds
99.99% <= 6 milliseconds
99.99% <= 7 milliseconds
100.00% <= 8 milliseconds
100.00% <= 9 milliseconds
100.00% <= 10 milliseconds
100.00% <= 11 milliseconds
100.00% <= 13 milliseconds
100.00% <= 14 milliseconds
100.00% <= 15 milliseconds
100.00% <= 16 milliseconds
100.00% <= 203 milliseconds
100.00% <= 204 milliseconds
100.00% <= 408 milliseconds
100.00% <= 828 milliseconds
100.00% <= 828 milliseconds
119703.13 requests per second

====== GET ======
  1000000 requests completed in 8.04 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.82% <= 1 milliseconds
99.96% <= 2 milliseconds
99.98% <= 3 milliseconds
99.99% <= 4 milliseconds
99.99% <= 5 milliseconds
100.00% <= 6 milliseconds
100.00% <= 7 milliseconds
100.00% <= 10 milliseconds
100.00% <= 12 milliseconds
100.00% <= 203 milliseconds
100.00% <= 412 milliseconds
100.00% <= 831 milliseconds
100.00% <= 832 milliseconds
100.00% <= 1663 milliseconds
100.00% <= 1664 milliseconds
100.00% <= 1664 milliseconds
124424.54 requests per second

** not that far behind, but percentile distribution is all over the place for Redex.
--------------------------------------------------------------------------------------
```

```
Let's add pipelining - https://redis.io/topics/pipelining
-P sets the pipeline param.

# Redis
➜  ~ redis-benchmark -t GET,SET -p 7000 -n 1000000 -P 10
====== SET ======
  1000000 requests completed in 0.90 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.80% <= 1 milliseconds
100.00% <= 1 milliseconds
1116071.38 requests per second

====== GET ======
  1000000 requests completed in 0.89 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.97% <= 1 milliseconds
100.00% <= 1 milliseconds
1119820.88 requests per second

# Damn 7s -> 0.9s, what if we pipeline more?
# Redis
➜  ~ redis-benchmark -t GET,SET -p 7000 -n 1000000 -P 50
====== SET ======
  1000000 requests completed in 0.61 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

6.63% <= 1 milliseconds
99.49% <= 2 milliseconds
99.74% <= 3 milliseconds
100.00% <= 3 milliseconds
1628664.38 requests per second

====== GET ======
  1000000 requests completed in 0.47 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

38.74% <= 1 milliseconds
99.49% <= 2 milliseconds
99.95% <= 3 milliseconds
100.00% <= 3 milliseconds
2136752.25 requests per second


# Okay lets check Redex
# Redex
➜  ~ redis-benchmark -t GET,SET -p 6000 -n 1000000 -P 10
====== SET ======
  1000000 requests completed in 6.16 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.84% <= 1 milliseconds
99.93% <= 2 milliseconds
99.98% <= 3 milliseconds
99.99% <= 4 milliseconds
99.99% <= 203 milliseconds
99.99% <= 204 milliseconds
100.00% <= 407 milliseconds
100.00% <= 408 milliseconds
100.00% <= 408 milliseconds
162443.14 requests per second

====== GET ======
  1000000 requests completed in 6.61 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

99.81% <= 1 milliseconds
99.93% <= 2 milliseconds
99.95% <= 3 milliseconds
99.96% <= 6 milliseconds
99.97% <= 203 milliseconds
99.98% <= 204 milliseconds
99.98% <= 411 milliseconds
99.98% <= 412 milliseconds
99.98% <= 835 milliseconds
99.99% <= 836 milliseconds
99.99% <= 1663 milliseconds
99.99% <= 1664 milliseconds
100.00% <= 3295 milliseconds
100.00% <= 3295 milliseconds
151217.30 requests per second

# more pipelining
# Redex
➜  ~ redis-benchmark -t GET,SET -p 6000 -n 1000000 -P 50
====== SET ======
  1000000 requests completed in 7.21 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

95.27% <= 1 milliseconds
99.14% <= 2 milliseconds
99.82% <= 3 milliseconds
99.90% <= 4 milliseconds
99.93% <= 207 milliseconds
99.94% <= 208 milliseconds
99.97% <= 412 milliseconds
100.00% <= 412 milliseconds
138657.80 requests per second

====== GET ======
  1000000 requests completed in 6.87 seconds
  50 parallel clients
  3 bytes payload
  keep alive: 1

96.30% <= 1 milliseconds
99.57% <= 2 milliseconds
99.80% <= 3 milliseconds
99.81% <= 4 milliseconds
99.85% <= 5 milliseconds
99.96% <= 204 milliseconds
99.98% <= 207 milliseconds
99.99% <= 208 milliseconds
100.00% <= 208 milliseconds
145581.59 requests per second

it's slower with more pipelining. 
```

Welp, I'll have to dig deep into the internals to properly comment on these, or maybe something is off in benchmarking?
If you can explain it, let us know :)

#### License

MIT

