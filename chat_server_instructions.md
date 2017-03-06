# Chat Server

## 1. Create new app

Plan out the app. My plan, if you'd like to follow along, is as follows:

> We'll build out a one-room chat server, which will keep as its state a list of
> all the chat content that has been posted in that server. People will be able
> to post chat content to it and get a list of chat content from it by sending
> messages to this server.

> After that's working, we'll add structure to our messages and make sure that
> they have both a `content` field and a `name` field.

> Once we have chat content with user information attached, we'll make a
> Supervisor for this chat room. This will allow us to make sure that the chat
> room is always up - even if we kill that process, the Supervisor will start a
> new one in its place.

> Finally, we'll update our server so that it can host multiple chat rooms at
> the same time.

The rest of these steps will help guide you as you implement this plan.

We'll start by running `mix new chat_server`, which will create a new app
called `chat_server`.

## 2. Create the one-room chat server

### 2.1 Start by setting up the server to store state with a `loop` function.

The state should be in the form of a List, but let's not trust our users to
know that: define a `loop` function that receives no arguments and calls
`loop`, passing it an empty list as an argument.

Define a `loop` function that receives a state and waits to receive a message.
If the message matches the format `{:get, from}`, then send the state back to
the process that requested it and continue looping with the same state.

Test your code by running:
```
pid = spawn(fn -> ChatServer.loop() end)
send(pid, {:get, self()})
flush() # => should return []
```

### 2.2 Add the ability to store chat content

Add another message matching clause to your `loop` function. If the message
matches the format `{:create, msg}`, then continue looping with that content
added to your state.

Test your code by running:
```
pid = spawn(fn -> ChatServer.loop() end)
send(pid, {:create, "hello world"})
send(pid, {:get, self()})
flush() # => should return ["hello world"]
send(pid, {:create, "hello again"})
send(pid, {:get, self()})
flush() # => should return ["hello world", "hello again"]
```

## 3. Add Message struct

Define a module `ChatServer.Message` that contains a struct definition. The
struct defined for this module should have a `content` property and a
`username` property.

Now, if a user passes content to the chat server, create a new Message struct
with the `content` property set to that content.

If, on the other hand, a user passes in a Map with a `content` property and a
`username` property, then create a new Message struct using those passed-in
properties.

Test your code by running:
```
pid = spawn(fn -> ChatServer.loop() end)
send(pid, {:create, "hello world"})
send(pid, {:get, self()})
flush() # => should return [%ChatServer.Message{content: "hello world", username: "anon"}]
send(pid, {:create, %{content: "hello world", username: "gage"}})
send(pid, {:get, self()})
flush() # => should return [%ChatServer.Message{content: "hello world", username: "anon"}, %ChatServer.Message{content: "hello world", username: "gage"}]
```

## 4. Create chat server Supervisor

### 4.1 Refactor chat server into a GenServer

#### 4.1.1 `use GenServer`

Once we have refactored the chat server to implement the GenServer behavior, we
will be able to fit it into a supervision tree very easily.

First, add `use GenServer` to the top of the module's definition. This allows
GenServer methods to be used throughout this module. Write a `start_link`
function that returns `GenServer.start_link(__MODULE__, :ok, [])`.

Test your code:
```
ChatServer.start_link # => {:ok, #PID<0.123.0>}
# this pid is your reference to that chat server
```

#### 4.1.2 Client API

Next, let's write some Client functions. These functions are the way that users
and other processes will interact with this module. Write:
+ A `get/1` function that receives `pid` and returns `GenServer.call(pid,
{:get})`
+ A `create/2` function that receives `pid` and `content` and returns
`GenServer.cast(pid, {:create, content})`

#### 4.1.3 Server callbacks

Now that we have an Client API for this chat server, let's build out the server
side. Server functions include:
+ `init/1`, which receives the second argument from the call to
`GenServer.start_link`
+ `handle_call/3`, which receives the request, who it's from, and the current
state
+ `handle_cast/2`, which receives the request and the state, and isn't expected
to reply



### 4.2 Create ChatServer.Supervisor

Create a new file, `chat_supervisor.ex`. It should contain the following code:
```
defmodule ChatServer.Supervisor do
  # allows this module to use all of the Supervisor module's functions
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(ChatServer, [ChatServer])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
```

## 5. Create multiple chat rooms

