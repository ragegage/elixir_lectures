Processes

isolated from each other, run concurrent to each other, communicate via message passing

create a new process using `spawn/1`:
```
pid = spawn fn -> 1 + 2 end
Process.alive?(pid)
```

access current process's pid using `self/0`

send messages to a process using `send/2`; receive messages using `receive/1`

sent messages get stored in the process's mailbox; `receive/1` searches the mailbox for a message that matches its patterns

`flush/0` flushes and prints all the messages in the mailbox

---

`spawn_link/1` spawns a new process and links that process to its parent process, allowing errors to propagate

this allows us to link processes to supervisor processes; the supervisors will detect a process failing and start a new process in its place

you don't need to catch or handle exceptions, because every process is isolated

---

`Task.start/1` and `Task.start_link/1` provide nicer interfaces for supervisors than spawn does

---

state is most commonly kept in processes that loop infinitely, maintain state, and send and receive messages

Note:
kv.exs demo:
```
{:ok, pid} = KV.start_link
send pid, {:get, :hello, self()}
flush() # nil
send pid, {:put, :hello, :world}
send pid, {:get, :hello, self()}
flush() # :world
```
---

Agents abstract this state logic into a process that you can interact with:
```
{:ok, pid} = Agent.start_link(fn -> %{} end)
Agent.update(pid, fn map -> Map.put(map, :hello, :world) end)
Agent.get(pid, fn map -> Map.get(map, :hello) end)
```

---

next steps to learn:

[mix and building a real app](http://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html)

---

OTP - Open Telecom Platform (a set of libraries that ship with Erlang -
supervision trees, event managers, &c.)

Mix - build tool that ships with Elixir (creating, compiling, testing, managing
dependencies, &c.)

ExUnit - unit testing framework the ships with Elixir

---

`mix new project_name` or `mix new modulename --module ProjectName`
`cd kv; mix compile` # Generated kv app
`iex -S mix` opens an iex session inside the app
`mix text` runs all tests inside the `test` folder
+ passed tests are represented by a `.`
+ failed tests output:
  + the location where the test was defined (e.g., `test/kv_test.exs:5`)
  + the left-hand side and the right-hand side of the `==`
  + a stack trace

`mix test #{path_to_test}` runs the specified test

---

Mix supports three environments: `:dev`, `:test`, and `:prod`

when running the app locally, the app runs in `:dev`
when running tests, the app runs in `:test`
you can set `MIX_ENV=prod mix compile` to set the environment

---

Processes:
+ Agent (simple wrappers around state)
+ GenServer (generic servers / processes)
+ GenEvent (generic event managers that allow publish events)
+ Task (async computation processes)

all use `send`, `receive`, `spawn`, `link`, &c.

---

Agents

```
{:ok, agent} = Agent.start_link fn -> [] end # {:ok, #PID<0.57.0>}
Agent.update(agent, fn list -> ["eggs" | list] end) # :ok
Agent.get(agent, fn list -> list end) # ["eggs"]
Agent.stop(agent) # :ok
```

think of an Agent as a server and the program talking to the Agent as the
client - when do you want to put expensive work on the server and when do you
want to put it on the client?

---

Tests

```
defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  test "stores values by key" do
    {:ok, bucket} = KV.Bucket.start_link
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end
end
```
`async: true` allows this test to be run concurrently with other async tests

can rewrite test to:
```
defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = KV.Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end
end
```

---

atoms are not garbage collected - so don't create atoms from user input! (they
could create enough to fill up system memory)

---

GenServers

accepts two types or requests:
+ calls -> synchronous, server must repond
+ casts -> async, server won't respond

via:
+ `handle_call/3` -> used for synchronous requests
+ `handle_cast/2` -> used for async requests that don't need a reply (i.e., not
often)
+ `handle_info/2` -> used for all other messages, incl. those sent with `send/2`
  + make sure to define a catch-all clause for `handle_info/2`

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

links are bi-directional (if one of two linked processes crashes, the other
will as well)

monitors are uni-directional (only the monitoring process will receive
notifications about the monitored one)

in general, don't link _and_ monitor a process - delegate the creation of
processes to supervisors

---

Supervisors

+ assign names to processes under supervision so that they can be restarted and
get a new pid without it being a headache
  + register the process under the same name of the module that defines it

Note:
sets up a supervisor to monitor a Registry
```
defmodule KV.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(KV.Registry, [KV.Registry])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
```

---

Application

mix starts the application by default unless you enter iex using the
`--no-start` flag (`iex -S mix run --no-start`)

you can add callbacks to start running modules when the Application starts:
```
def application do
  [extra_applications: [:logger],
   mod: {MODULE_NAME, []}]
end
```
the module that will be called needs to implement the `Application` behaviour; particularly the `start/2` (and maybe the `stop/1`) function:
```
defmodule KV do
  use Application

  def start(_type, _args) do
    KV.Supervisor.start_link
  end
end
```

---

to make one supervisor spawn and supervise many children workers, use the
supervisor strategy `:simple_one_for_one`

Note:
using the strategy :simple_one_for_one
```
defmodule KV.Bucket.Supervisor do
  use Supervisor

  # ...
  
  def init(:ok) do
    children = [
      worker(KV.Bucket, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
```
starting buckets:
```
{:ok, pid} = KV.Bucket.Supervisor.start_bucket
ref = Process.monitor(pid)
refs = Map.put(refs, ref, name)
names = Map.put(names, name, pid)
{:noreply, {names, refs}}
```

---

Supervisor Trees: when supervisors supervise other supervisors

supervisor strategies:
+ :simple_one_for_one
+ :one_for_one
+ :one_for_all - kill and restart all children processes whenever any one of
them dies
+ :rest_for_one - when a child process crashes, kill and restart child
processes that were started after the crashed child

---

Observer

`:observer.start` brings up a GUI with the following functionality:
+ you can select your application and see the supervisors & processes your
application is spawning
+ you can double-click a process and access information about it
+ you can right-click a process to send a "kill signal" (a way to emulate
failures)

---

ETS

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

Applications & Umbrella projects

It makes more sense in Elixir to have multiple small applications in a project
rather than one monolithic project-cum-application. Umbrella projects are
projects that host multiple applications.

`mix new kv_umbrella --umbrella` will create:
```
+ kv_umbrella
  + apps
```
cd into `apps`, generate a module with a supervision tree
```
cd kv_umbrella/apps
$ mix new kv_server --module KVServer --sup
```

---