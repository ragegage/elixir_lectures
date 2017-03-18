# Umbrella Apps

"never write large apps"
- Abraham Lincoln

---

Umbrella apps allow you to break up an app into multiple independent services that can interact with each other

---

`mix new APP_NAME --umbrella`

this app has an `apps` subfolder that holds other applications

("application" means service in this case)

---

# Phoenix

["Rails for Elixir"](http://rob.conery.io/2016/02/10/let-s-build-something-with-elixir/)

[Rails vs. Phoenix](https://littlelines.com/blog/2014/07/08/elixir-vs-ruby-showdown-phoenix-vs-rails)

[2M simultaneous users]( http://www.phoenixframework.org/blog/the-road-to-2-million-websocket-connections)

[Phoenix fans troll Rails](https://github.com/BlakeWilliams/rails)

---

## Agenda

+ setup (install phoenix & run server)
+ outline of phoenix architecture
+ build app

---

### install phoenix:

http://www.phoenixframework.org/docs/installation

---

### create phoenix app

`mix phoenix.new APP_NAME`

`mix ecto.create`

`mix phoenix.server` -> localhost:4000

---

### phoenix architecture

`/web` folder holds:

+ the `router`
+ `controllers`
+ `templates`
+ `views`
+ `channels`
+ `priv/static` holds static assets (css, images, js)
+ `web/static` holds assets that need to be built (webpack, scss)
+ `lib` holds the app's endpoint and other files that don't get recompiled between requests (e.g., if you need to store state between requests)

---

### router

`METHOD "/ROUTE", CONTROLLER_NAME, :CONTROLLER_METHOD`

`get "/hello", HelloController, :index`

`get "/hello/:message", HelloController, :show`

`resources "/users", UserController`

Note:
route params are passed as a Map, with string keys

---

### controllers

```
defmodule HelloPhoenix.HelloController do
  use HelloPhoenix.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def show(conn, %{"message" => message}) do
    render conn, "show.html", message: message
  end
end
```

Note:
`conn` is a struct that holds data about the request
`params` are the request's parameters
  if you're not going to use the params, mark them with a `_`
  you can pattern match against them (remember, they're a Map)
`render conn, VIEW` finds the view in `web/templates/CONTROLLER_NAME` and tells the view to render it

---

### views

phoenix views render templates and also prepare data for use in the template

```
defmodule TestApp.HelloView do
  use TestApp.Web, :view
end
```

Note:
the "X" in "XController" must match the "X" in "XView"

---

### templates

phoenix templates use `.eex` by default -> embedded elixir (like `.erb`)

```
<div class="jumbotron">
  <h2>Hello World, from Phoenix!</h2>
</div>
```

loops over list of users, called user template for each user
```
<%= for user <- users @conn do %>
  <%= @user %>
  <!-- equivalent to:
    <%= render HelloPhoenix.PageView, "user.html", user: user %>
  -->
<% end %>
```

Note:
the "X" in "XController" shuold also be in the path to the template:
`web/templates/X/index.html.eex`

just like rails, there is a `layout` html

just like rails, `<%= %>` writes code output into html

just like rails, you use `@variable` to refer to a variable passed in from a
controller; unlike rails, `@` is short here for `Map.get(assigns, :variable)`

---

### channels

send / receive messages via a socket

handlers - authenticate and identify socket connections
routes - defined in socket handlers; match on topic string
channels - similar to controllers, persist beyond one request/response cycle

Note:

### channels, con't.

+ methods: `join/3`, `terminate/2`, `handle_in/3`, `handle_out/3`
+ messages - struct with `topic`, `event`, `payload`, and `ref`
+ topics - string identifiers
+ transports - handle message dispatching into and out of a channel
+ transport adapters - websockets with a fallback to longpolling, or custom
+ client libraries - phoenix ships with a JS client; can get other clients as well


`web/channels/user_socket.ex` -> write channels into the `## Channels` section

create `web/channels/room_channel.ex`; implement `join/3`: (update with my demo code)
```
defmodule HelloPhoenix.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end
  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end
end
```
configure the chat room/s in `web/channels/room_channel.ex`

use phoenix's js bindings for sockets to accept input and handle `new_msg` events by writing those messages to the html (`web/static/js/socket.js`)

write some simple html into `web/templates/page/index.html.eex` to hold text input and messages

(back in `room_channel.ex`)
incoming events are caught by `handle_in/3`; outgoing events are send by using `broadcast!/3` (calls a `handle_out/3` function that is implemented by default)

```
def handle_in("new_msg", %{"body" => body}, socket) do
  broadcast! socket, "new_msg", %{body: body}
  {:noreply, socket}
end

def handle_out("new_msg", payload, socket) do
  push socket, "new_msg", payload
  {:noreply, socket}
end
```
^ we can overwrite the default `handle_out/3` function to allow our chat app to
intercept (i.e., not broadcast) certain events or types of events

---

### schemas
#### ("models" in Rails)

handled by **Ecto**

+ migrations
  + `mix ecto.create`
  + `mix ecto.gen.migration create_dogs`
  + `mix ecto.migrate`

+ changesets are the equivalent of rails validations

---

### phoenix's scaffold

`mix phoenix.gen.html User users name:string email:string bio:string number_of_pets:integer`

creates a migration, controller, controller test, model, model test, view, templates

---

### controller methods

(using models in controllers)

**very similar to rails controllers**

Note:

```
# UserController

alias HelloPhoenix.User # allows us to just use User

def index(conn, _params) do
  # select all users
  users = Repo.all(User)
  # render all users into index.html
  render(conn, "index.html", users: users)
end

def show(conn, %{"id" => id}) do
  user = Repo.get!(User, id)
  render(conn, "show.html", user: user)
end

def new(conn, _params) do
  changeset = User.changeset(%User{})
  render(conn, "new.html", changeset: changeset)
end

def create(conn, %{"user" => user_params}) do
  changeset = User.changeset(%User{}, user_params)

  case Repo.insert(changeset) do
    {:ok, _user} ->
      conn
      |> put_flash(:info, "User created successfully.")
      |> redirect(to: user_path(conn, :index))
    {:error, changeset} ->
      render(conn, "new.html", changeset: changeset)
  end
end

def edit(conn, %{"id" => id}) do
  user = Repo.get!(User, id)
  changeset = User.changeset(user)
  render(conn, "edit.html", user: user, changeset: changeset)
end

def update(conn, %{"id" => id, "user" => user_params}) do
  user = Repo.get!(User, id)
  changeset = User.changeset(user, user_params)

  case Repo.update(changeset) do
    {:ok, user} ->
      conn
      |> put_flash(:info, "User updated successfully.")
      |> redirect(to: user_path(conn, :show, user))
    {:error, changeset} ->
      render(conn, "edit.html", user: user, changeset: changeset)
  end
end

def delete(conn, %{"id" => id}) do
  user = Repo.get!(User, id)

  # Here we use delete! (with a bang) because we expect
  # it to always work (and if it does not, it will raise).
  Repo.delete!(user)

  conn
  |> put_flash(:info, "User deleted successfully.")
  |> redirect(to: user_path(conn, :index))
end
```

---

### associations

`has_many`, `belongs_to`, `has_one`

rails' `includes` is called `preload` in phoenix:
`users = User |> Repo.all |> Repo.preload([:videos])`

Note:
```
# command line
mix phoenix.gen.model Video videos name:string approved_at:datetime description:text likes:integer views:integer user_id:references:users
# note the "user_id:references:users" - that sets up the association in the Video model
```
```
# Video model
schema "videos" do
  field :name, :string
  field :approved_at, Ecto.DateTime
  field :description, :string
  field :likes, :integer
  field :views, :integer
  belongs_to :user, HelloPhoenix.User

  timestamps()
end
```
```
# User model
schema "users" do
  field :name, :string
  field :email, :string
  field :bio, :string
  field :number_of_pets, :integer

  # association with videos table
  has_many :videos, HelloPhoenix.Video

  timestamps()
end
```
---

### sessions

```
conn = put_session(conn, :session_token, "session token value here")
message = get_session(conn, :session_token)
```

---

ty