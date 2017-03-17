# Umbrella Apps

Umbrella apps are Elixir's way of supporting the suggestion to "never write large apps." Umbrella apps allow multiple apps to live in the same project and reference each other's functions.

1. `mix new app_name --umbrella`
1. move chat server project into `/apps`
1. `mix phoenix.new chat_web`

These two apps are now living in the same umbrella app and thus can interact with each other.

# Chat

This project will involve creating an umbrella app that combines a Phoenix web app with the ChatServer
app (solutions available at https://github.com/ragegage/chat_server).

## Combining the two apps

`mix new Chat --umbrella`

Move the ChatServer app into the `apps` folder in the new Chat app.

## Build a Chat Web App

The instructions for creating a chat app with Phoenix largely cover
creating the web portion of this app; the only parts that have changed
are the ChatWeb.RoomChannel module and the frontend code.

### Create a new Phoenix App

`mix phoenix.new APP_NAME`

#### Designate the default channel

In the user socket file (`web/channels/user_socket.ex`), designate the default channel (e.g., `room:lobby`).

### Create a channel handler

The RoomChannel module will be in charge of connecting sessions to the appropriate socket and, eventually, receiving messages and broadcasting them out to all other users connected to that socket. It will have a `join/3` method that receives: 

+ the channel you designated in the previous step (e.g., `room:lobby`)
+ any message sent along with the channel join request
+ the socket

and returns `{:ok, socket}`. It should also return an error tuple if someone tries to join a different room.

Create `web/channels/room_channel.ex` and write the RoomChannel module.

Note:
```
defmodule Chat.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end
  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end
end
```

### Edit the frontend socket code

#### Socket.js

Edit `web/static/js/socket.js` so that its channel matches the RoomChannel
module.

#### App.js

`import from "./socket"` in `web/static/js/app.js`

#### HTML template

set up `web/templates/page/index.html.eex` to hold a list of chat messages and
an input to create new ones

e.g.,
```
<ul id="messages"></ul>
<input id="chat-input" type="text"></input>
```

#### Socket.js event listeners

Add event listeners to `web/static/js/socket.js` to write messages to the `ul`
and read messages from the `input`

e.g.,
```
let channel           = socket.channel("room:lobby", {})
let chatInput         = document.querySelector("#chat-input")
let messagesContainer = document.querySelector("#messages")

chatInput.addEventListener("keypress", event => {
  if(event.keyCode === 13){
    channel.push("new_msg", {body: chatInput.value})
    chatInput.value = ""
  }
})

channel.on("new_msg", payload => {
  let messageItem = document.createElement("li");
  messageItem.innerText = `[${Date()}] ${payload.body}`
  messagesContainer.appendChild(messageItem)
})

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
```

### Add message handling to the RoomChannel

Now that our frontend is configured to send messages over the socket whenever a user enters text into the input, let's configure the RoomChannel module to handle the reception of those messages.

Set up the room channel to broadcast new messages to all subscribers.

e.g.,
```
def handle_in("new_msg", %{"body" => body}, socket) do
  broadcast! socket, "new_msg", %{body: body}
  {:noreply, socket}
end
```

### Test the app

Try opening this app in multiple incognito windows and make sure that posted messages are visible to all users.

## Modify the Chat Web App

ChatWeb.RoomChannel should now start a link to the ChatServer.Supervisor and
start a room whenever a user joins a room. If that room already
exists, the list of previous chats from that room are returned to the
frontend along with the socket.

The frontend only updates one handler from the other set of chat app
instructions: the response callback after a user joins a channel. The
frontend now receives all previous messages from that channel from the
backend, and so it adds each message to the unordered list of messages.

## Add room creation

Next, let's implement the ChatServer feature where users can create
their own chat rooms named whatever they want.

To do this, we'll need a way for users of our web app to input a chat
room name, and tell our server to let people join whatever room they
want.

## TODO: Display list of rooms

Next, let's keep a list of rooms on the page at all times. A room will get added to the list once the user has joined it.

## TODO: Display list of online users (using Presence)

## TODO: Track idle-ness of online users (??)
