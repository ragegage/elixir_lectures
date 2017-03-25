# Chat Umbrella App

This project will involve creating an umbrella app that combines a Phoenix web app with the ChatServer
app (solutions available at https://github.com/ragegage/chat_server). The Phoenix app will be able to 
call the ChatServer app's functions, thus allowing users to interact with your ChatServer over the internet.

## 1. Combining the two apps

`mix new Chat --umbrella`

Move the ChatServer app into the `apps` folder in the new Chat app.

## 2. Build a Chat Web App

The instructions for creating a chat app with Phoenix largely cover
creating the web portion of this app; the only parts that have changed
are the ChatWeb.RoomChannel module and the frontend code.

Install Phoenix here: [http://www.phoenixframework.org/docs/installation](http://www.phoenixframework.org/docs/installation).

Note: If you get a `Could not start node watcher because script ".../brunch"
does not exist` error, `cd` into the `chat_web` app and run `npm install` to
set up the ChatWeb app's JavaScript dependencies.

### 2.1 Create a new Phoenix App

`mix phoenix.new APP_NAME`

#### 2.1.1 Designate the default channel

In the user socket file (`web/channels/user_socket.ex`), change the default 
channel from `room:*` to `room:lobby`.

### 2.2 Create a channel handler

The RoomChannel module will be in charge of connecting sessions to 
the appropriate socket and, eventually, receiving messages and 
broadcasting them out to all other users connected to that socket. 
It will have a `join/3` method that receives: 

+ the channel you designated in the previous step (e.g., `room:lobby`)
+ any message sent along with the channel join request
+ the socket

and returns `{:ok, socket}`. It should also return an error tuple if 
someone tries to join a different room.

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

### 2.3 Edit the frontend socket code

#### 2.3.1 Socket.js

Edit `web/static/js/socket.js` so that its channel matches the RoomChannel
module.

#### 2.3.2 App.js

`import from "./socket"` in `web/static/js/app.js`

#### 2.3.3 HTML template

set up `web/templates/page/index.html.eex` to hold a list of chat messages and
an input to create new ones

e.g.,
```
<ul id="messages"></ul>
<input id="chat-input" type="text"></input>
```

#### 2.3.4 Socket.js event listeners

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

### 2.4 Add message handling to the RoomChannel

Now that our frontend is configured to send messages over the socket whenever a user enters text into the input, let's configure the RoomChannel module to handle the reception of those messages.

Set up the room channel to broadcast new messages to all subscribers.

e.g.,
```
def handle_in("new_msg", %{"body" => body}, socket) do
  broadcast! socket, "new_msg", %{body: body}
  {:noreply, socket}
end
```

### 2.5 Test the app

Try opening this app in multiple incognito windows and make sure that 
posted messages are visible to all users.

## 3. Modify the Chat Web App

ChatWeb.RoomChannel should now start a room whenever a user joins a room. 
If that room already exists, the list of previous chats from that room 
should be returned to the frontend along with the socket.

In order for `start_room/1` to work, however, we'll need the 
ChatServer.Supervisor to have already been started. To set up the 
application so that it starts the Supervisor automatically, follow these
steps:

Adding ChatServer.Supervisor to your list of extra applications will ensure
that it is started (its `start` method will be called) when the application 
starts, with a given list of arguments passed to it.

+ Add the ChatServer.Supervisor to your ChatServer app's `mix.exs' file
  + ```
    def application do
      [extra_applications: [:logger],
       mod: {ChatServer.Supervisor, []}]
    end
    ```
+ Add `use Application` to your ChatServer.Supervisor module
+ Implement `start/2` in ChatServer.Supervisor; it should call `start_link/0`

All of the apps in your umbrella app are compiled together, so you can call 
functions from the ChatServer from the ChatWeb module.

The frontend only updates one handler from the other set of chat app
instructions: the response callback after a user joins a channel. The
frontend now receives all previous messages from that channel from the
backend, and so it adds each message to the unordered list of messages.

## 4. Add room creation

Next, let's implement the ChatServer feature where users can create
their own chat rooms named whatever they want.

To do this, we'll need a way for users of our web app to input a chat
room name, and tell our server to let people join whatever room they
want.

## 5. Display list of rooms

Next, let's keep a list of rooms on the page at all times. A room will get added to the list once the user has joined it.

## 6. Display list of online users (using Presence)

## 7. Require login to access chat
