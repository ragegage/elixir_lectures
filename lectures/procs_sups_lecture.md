# OOPS

+ Dominick & Preston
+ elixir-lang.org
+ `r ModuleName` to reload it
+ `IEx.pry` & `respawn`
+ MSH Labs

---

# OTP

(Open Telecom Platform)

+ Erlang
+ Tools & libraries
+ System design principles

Note:
OTP consists of these three things

---

## Processes

+ isolated from each other
  + each process has its own memory heap and garbage collector
+ run concurrent to each other
+ communicate via message passing

Note:
OOP?

---

## Processes, con't.

+ `spawn/1` creates a new process out of a function
+ `self/0` gives access to current process's pid
+ `send/2` send messages to a process
  + sent messages get stored in the recipient's mailbox
+ `receive/1` searches the mailbox for a message that matches its patterns
+ `flush/0` flushes and prints all the messages in the mailbox

---

## State

State is most commonly kept in processes that loop infinitely, maintain state, and send and receive messages

---

### Simple Counter state example

Note:
this and further demos are in elixir_processes_demo.ex

---

### Counter state example with API

---

## Agents

Agents are wrappers for this looping state idea

#### API

+ `start_link/1`
+ `update/2`
+ `get/2`
+ `stop/1`

---

### Agent refactor

Note:
source for this and the previous few slides: http://dantswain.herokuapp.com/blog/2015/01/06/storing-state-in-elixir-with-processes/

---

## GenServers

a GenServer is a loop that handles one request per iteration passing along an updated state

accepts two types or requests:

+ calls -> synchronous, server must repond
+ casts -> async, server won't respond

Note:
this is an example of monitoring a process and getting a message when it stops
running
```
{:ok, pid} = Agent.start_link(fn -> [] end) # {:ok, #PID<0.91.0>}
Process.monitor pid # #Reference<0.0.4.150>
Agent.stop pid # :ok
flush() # {:DOWN, #Reference<0.0.4.150>, :process, #PID<0.91.0>, :normal}
flush # :ok
```

---

GenServer refactor

---

## Structs

can define a struct that holds state information:
`defstruct [id: nil, items: [], key: nil]`

create that struct using input like so:
`struct(%AppName.ProcessName{}, map_of_input_values)`

and edit like so:
`%{struct_name | items: List.insert_at(struct_name.items, -1, item)}`
(this updates the `items` key and leaves the rest unchanged)

---

## Supervisors

Supervisors keep track of processes and can restart them if they crash

#### Tips
+ assign names to processes under supervision so that they can be restarted and get a new pid without it being a headache
  + register the process under the same name of the module that defines it

---

### Supervision Trees: when supervisors supervise other supervisors

#### supervisor strategies:

+ :one_for_one - if a child dies, it will be the only one restarted
+ :simple_one_for_one - specify a worker template and supervise many children based on this template
+ :one_for_all - kill and restart all children processes whenever any one of
them dies
+ :rest_for_one - when a child process crashes, kill and restart child
processes that were started after the crashed child

---

## Extra Stuff

---

### Observer

`:observer.start` brings up a GUI with the following functionality:

+ you can select your application and see the supervisors & processes your
application is spawning
+ you can double-click a process and access information about it
+ you can right-click a process to send a "kill signal" (a way to emulate
failures)

---

### :sys

allows you to trace a process's state

+ :sys.get_state(pid)
+ :sys.get_status(pid)
+ :sys.trace(pid, true)
+ :sys.no_debug(pid)
+ :sys.statistics(pid, true)

---

### ETS

Erlang Term Storage can be used as a cache
+ log and analyze your application to find bottlenecks; this will let you know
what to cache
+ data can be read asynchronously; this might produce race conditions

```
table = :ets.new(:table, [:named_table, read_concurrency: true]) # 8207
:ets.insert(:table, {"foo", self()}) # true
:ets.lookup(:table, "foo") # [{"foo", #PID<0.41.0>}]
```

---

### Persistence

+ SQL
+ documents (mnesia, mongo, rethinkdb)
+ no persistence (in-memory storage: ETS)

---

# Mix

Mix is the build tool that ships with Elixir (creating applications, compiling, testing, managing dependencies, &c.)

---

### Errata

there is a limit on the number of current alive (running) processes: 32,768

---

ty
