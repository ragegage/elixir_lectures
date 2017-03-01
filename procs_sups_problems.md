Processes & Supervisors problems

1. Chat Server

start with one room
  can post messages to it
  can get list of messages from it

messages have names attached

create a supervisor for the chat room
  change pid to name
  test with Process.whereis(:chat_room) |> Process.exit(:kill)

can create multiple rooms (use Registry)

(source: https://m.alphasights.com/process-registry-in-elixir-a-practical-example-4500ee7c0dcc#.8d5e2tn27)
note: replace the :gproc with Registry in the :via tuple a lá https://hexdocs.pm/elixir/master/Registry.html

2. More Complicated Problem
