
# Intro to Elixir

Agenda:

+ what is elixir
+ simple demo
+ processes demo

Note:
[main source](http://elixir-lang.org/getting-started/introduction.html)

---

## elixir & erlang:

### known for
+ concurrency
+ fault tolerance
+ distribution
+ high availability
<br/><br/>
### features
+ immutable
+ functional
+ process-based

Note:
Erlang was WhatsApp's "secret sauce" - https://blog.whatsapp.com/170/ONE-MILLION%21?p=170

helped bleacherreport scale ridiculously - https://cdn.ampproject.org/c/www.techworld.com/apps/how-elixir-helped-bleacher-report-handle-8x-more-traffic-3653957/?amp

Erlang ("Ericsson language") is a component of Ericsson, which has about a 35 percent global market share in the wireless network infrastructure.

Elixir was created by José Valim, a Rails core team member, in 2011.

2mil simultaneous users: http://www.phoenixframework.org/blog/the-road-to-2-million-websocket-connections

[intro to erlang](http://learnyousomeerlang.com/introduction)

[pros and cons of erlang](http://learnyousomeerlang.com/introduction#kool-aid)

[concurrency](http://learnyousomeerlang.com/the-hitchhikers-guide-to-concurrency)

http://highscalability.com/blog/2014/2/26/the-whatsapp-architecture-facebook-bought-for-19-billion.html

http://blog.carbonfive.com/2016/04/19/elixir-and-phoenix-the-future-of-web-apis-and-apps/

Hex is the package manager for elixir

---

## Simple Demos

Note:

lists are stored in memory as linked lists; prepending elements is O(1) but finding the length is O(n).

because data types are immutable in elixir, the original tuple isn't changed.

tuples are stored contiguously in memory; finding the length is O(1) but changing elements is O(n) because it requires copying the tuple's entire contents to a new tuple.

(you can use the `^` operator to pattern match against a variable's value:)

if you don't care about a value in a pattern, you can use `_` to fill that space.

you can compile modules using the `elixirc` command in the terminal (e.g., `elixirc math.ex`)

you can also compile and run `.exs` files without creating a `.beam` file like so: `elixir math.exs`

inside modules, `def` creates public functions while `defp` creates private functions

functions can have guards

no `for` loops in elixir - only recursion!

but in general, use the `Enum` module, which has most of the normal functions in it (`reduce`, `map`, &c.)

`Enumerable` is similar to ruby's: the functions work with any data type that implements its protocol.

you can pipe the results of a function directly into another function using `|>`

---

## Less Simple Demos

Note:

Processes:
isolated from each other, run concurrent to each other, communicate via message passing
create a new process using `spawn/1`:

access current process's pid using `self/0`

send messages to a process using `send/2`; receive messages using `receive/1`

sent messages get stored in the process's mailbox; `receive/1` searches the mailbox for a message that matches its patterns

`flush/0` flushes and prints all the messages in the mailbox

`spawn_link/1` spawns a new process and links that process to its parent process, allowing errors to propagate

this allows us to link processes to supervisor processes; the supervisors will detect a process failing and start a new process in its place

you don't need to catch or handle exceptions, because every process is isolated

`Task.start/1` and `Task.start_link/1` provide nicer interfaces for supervisors than spawn does

state is most commonly kept in processes that loop infinitely, maintain state, and send and receive messages

Agents abstract this state logic into a process that you can interact with:

when a process dies, it sends an `exit` signal (you can also send them manually
a lá `spawn_link fn -> exit(1) end`)

process supervisors listen for `exit` signals from their subordinate processes
and, on the occasion that they get them, restart the process that failed.

### Processes:

+ Agent (simple wrappers around state)
+ GenServer (generic servers / processes)
+ GenEvent (generic event managers that allow publish events)
+ Task (async computation processes)

all use `send`, `receive`, `spawn`, `link`, &c.


think of an Agent as a server and the program talking to the Agent as the
client - when do you want to put expensive work on the server and when do you
want to put it on the client?

GenServers:
accepts two types or requests:
+ calls -> synchronous, server must repond
+ casts -> async, server won't respond
via:
+ `handle_call/3` -> used for synchronous requests
+ `handle_cast/2` -> used for async requests that don't need a reply (i.e., not
often)
+ `handle_info/2` -> used for all other messages, incl. those sent with `send/2`
  + make sure to define a catch-all clause for `handle_info/2`

links are bi-directional (if one of two linked processes crashes, the other
will as well)

monitors are uni-directional (only the monitoring process will receive
notifications about the monitored one)

in general, don't link _and_ monitor a process - delegate the creation of
processes to supervisors

Supervisors:
+ assign names to processes under supervision so that they can be restarted and
get a new pid without it being a headache
  + register the process under the same name of the module that defines it

to make one supervisor spawn and supervise many children workers, use the
supervisor strategy `:simple_one_for_one`


Supervisor Trees: when supervisors supervise other supervisors

supervisor strategies:
+ :simple_one_for_one
+ :one_for_one
+ :one_for_all - kill and restart all children processes whenever any one of
them dies
+ :rest_for_one - when a child process crashes, kill and restart child
processes that were started after the crashed child

Observer

`:observer.start` brings up a GUI with the following functionality:
+ you can select your application and see the supervisors & processes your
application is spawning
+ you can double-click a process and access information about it
+ you can right-click a process to send a "kill signal" (a way to emulate
failures)

---

\#eof
