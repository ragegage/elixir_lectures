defmodule SimpleCounter do
  def go do
    loop(0)
  end

  defp loop(n) do
    receive do
      {:click, from} ->
        send(from, n + 1)
        loop(n + 1)
    end
  end
end

pid = spawn(&SimpleCounter.go/0)
send(pid, {:click, self()})
receive do x -> x end
flush


defmodule Counter do
  # API methods
  def new do
    spawn fn -> loop(0) end
  end

  def set(pid, value) do
    send(pid, {:set, value, self()})
    receive do x -> x end
  end

  def click(pid) do
    send(pid, {:click, self()})
    receive do x -> x end
  end

  def get(pid) do
    send(pid, {:get, self()})
    receive do x -> x end
  end

  # Counter implementation
  defp loop(n) do
    receive do
      {:click, from} ->
        send(from, n + 1)
        loop(n + 1)
      {:get, from} ->
        send(from, n)
        loop(n)
      {:set, value, from} ->
        send(from, :ok)
        loop(value)
    end
  end
end

c = Counter.new
Counter.click(c)
Counter.get(c)
Counter.set(c, 42)
Counter.get(c)
c2 = Counter.new
Counter.get(c2)


defmodule CounterAgent do
  def new do
    Agent.start_link(fn -> 0 end)
  end

  def click(pid) do
    Agent.get_and_update(pid, fn(n) -> {n + 1, n + 1} end)
  end

  def set(pid, new_value) do
    Agent.update(pid, fn(_n) -> new_value end)
  end

  def get(pid) do
    Agent.get(pid, fn(n) -> n end)
  end
end

{:ok, agent} = CounterAgent.new
CounterAgent.get agent
CounterAgent.click agent
CounterAgent.get agent  
CounterAgent.set agent, 5
CounterAgent.get agent


defmodule CounterServer do
  use GenServer

  # API
  def new do
    GenServer.start_link(__MODULE__, 0)
  end

  def click(pid) do
    GenServer.call(pid, :click)
  end

  def set(pid, new_value) do
    GenServer.call(pid, {:set, new_value})
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  # GenServer callbacks

  # init(arguments) -> {:ok, state}
  # see http://elixir-lang.org/docs/v1.0/elixir/GenServer.html
  def init(n) do
    {:ok, n}
  end

  # handle_call(message, from_pid, state) -> {:reply, response, new_state}
  # see http://elixir-lang.org/docs/v1.0/elixir/GenServer.html
  def handle_call(:click, _from, n) do
    {:reply, n + 1, n + 1}
  end
  def handle_call(:get, _from, n) do
    {:reply, n, n}
  end
  def handle_call({:set, new_value}, _from, _n) do
    {:reply, :ok, new_value}
  end
end

{:ok, genserver} = CounterServer.new
CounterServer.get genserver
CounterServer.click genserver
CounterServer.get genserver  
CounterServer.set genserver, 5
CounterServer.get genserver
