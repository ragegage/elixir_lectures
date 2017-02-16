# Phoenix

"Rails for Elixir"

http://blog.carbonfive.com/2016/04/19/elixir-and-phoenix-the-future-of-web-apis-and-apps/

2mil simultaneous users: http://www.phoenixframework.org/blog/the-road-to-2-million-websocket-connections

## Agenda

+ setup (install phoenix & run server)
+ outline of phoenix architecture
+ build app

---

### install phoenix:

install elixir
`mix local.hex` to install Hex
`mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez` (from http://www.phoenixframework.org/docs/installation)
say yes to everything

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

`priv/static` holds static assets (css, images, js)
`web/static` holds assets that need to be built (webpack, scss)
`lib` holds the app's endpoint and other files that don't get recompiled between requests (e.g., if you need to store state between requests)

---

### router

`METHOD "/ROUTE", CONTROLLER_NAME, :CONTROLLER_METHOD`
`get "/hello", HelloController, :index`
`get "/hello/:message", HelloController, :show`

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
  + methods: `join/3`, `terminate/2`, `handle_in/3`, `handle_out/3`
pubsub - used under the hood; shouldn't be directly used in an app
messages - struct with `topic`, `event`, `payload`, and `ref`
topics - string identifiers
transports - handle message dispatching into and out of a channel
transport adapters - websockets with a fallback to longpolling, or custom
client libraries - phoenix ships with a JS client; can get other clients as well

Note:

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

#### what phoenix does for us

+ phoenix handles channel crashes and automatic reconnections
+ phoenix handles re-sending messages from client to server if a connection is
temporaily lost
+ messages don't persist on the server by default, so if a client misses a
message, they have missed it

---

### schemas
#### (models)

handled by **Ecto**

+ migrations (`mix ecto.gen.migration create_dogs`) (like rails)
  + migrate using `mix ecto.migrate` / `mix ecto.rollback`
+ schemas are the equivalent of rails models
  + schemas structure the table's information
  + `p = %APP_NAME.SCHEMA_NAME{}` is the equivalent of `u = User.new`
    + `%{p | age: 15}` is the equivalent of `u.age = 15`
  + `APP_NAME.Repo.insert(p)`
+ changesets are the equivalent of rails validations
  + `changeset = APP_NAME.SCHEMA_NAME.changeset(OLD_VALUE, CHANGES)`
  + `changeset.errors` is like `u.errors` after you call `u.valid?`
  + `changeset.valid?` is like `u.valid?`
  + `APP_NAME.Repo.insert(changeset)`
    + returns `{:error, changeset}` if the insert failed
  + `APP_NAME.Repo.insert!(changeset)`
    + errors out if the insert failed

Note:
requires a supervision tree

migrations:
```
def change do
  create table(:people) do
    add :first_name, :string
    add :last_name, :string
    add :age, :integer
  end
end
```

schemas:
```
schema "people" do
  field :first_name, :string
  field :last_name, :string
  field :age, :integer
end
```

changesets:
```
def changeset(person, params \\ %{}) do
  person
    # casting is kind of like rails' `permit`
  |> Ecto.Changeset.cast(params, [:first_name, :last_name, :age])
    # obvious what it does - these values are required
  |> Ecto.Changeset.validate_required([:first_name, :last_name])
end
```

---

### querying

+ `APP_NAME.SCHEMA_NAME |> Ecto.Query.first |> APP_NAME.Repo.one`
  + equivalent to `Person.first` in rails
+ `APP_NAME.SCHEMA_NAME |> APP_NAME.Repo.all`
  + equivalent to `Person.all` in rails
+ `APP_NAME.SCHEMA_NAME |> Ecto.Query.where(last_name: "Smith") |> APP_NAME.Repo.all`
  + equivalent to `Person.where(last_name: "Smith")` in rails
+ `APP_NAME.SCHEMA_NAME |> APP_NAME.Repo.get(^id)`
  + equivalent to `Person.find(:id)` in rails
+ `APP_NAME.SCHEMA_NAME |> APP_NAME.Repo.get_by(first_name: "Gage")`
  + equivalent to `Person.find_by(first_name: "Gage")` in rails

can chain queries (just like rails)

---

### updating

```
person = Friends.Person |> Ecto.Query.first |> Friends.Repo.one
changeset = Friends.Person.changeset(person, %{first_name: "Rage"})
Friends.Repo.update(changeset) do
  {:ok, person} -> # do something with person
  {:error, changeset} -> # do something with changeset
end
```

---

### deleting

```
person = Friends.Repo.get(Friends.Person, 1)
Friends.Repo.delete(person)
```

---

### phoenix's scaffold

command line: `mix phoenix.gen.html RESOURCE TABLE_NAME ATTR1:TYPE ATTR2:TYPE`
e.g., `mix phoenix.gen.html User users name:string email:string bio:string number_of_pets:integer`
  + migration, controller, controller test, model, model test, view, templates

`web/router.ex`: `resources "/users", UserController`

command line: `mix ecto.create` & `mix ecto.migrate`
  + create and run migrations on DB

command line: `mix phoenix.server`
  + start server, can interact with controllers through views

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

### keeping track of online users

`mix phoenix.gen.presence`

Note:
http://work.stevegrossi.com/2016/07/11/building-a-chat-app-with-elixir-and-phoenix-presence/

`Presence` in JavaScript has `syncState` and `syncDiff` methods that update the frontend object to match the backend's data

---

