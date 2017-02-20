# auth

Note:
mix phoenix.new login_app
mix ecto.create

remember, `iex -S mix` is equivalent to `rails c`
---

+ models
  + user
+ controllers
  + user
  + session
+ views
+ templates
  + sign up
  + log in
  + user show

---

## create user model

Note:
mix phoenix.gen.model User users email:string password_digest:string

---

## migration

Note:
add `null:false` to email; `create unique_index(:users, [:email])`

---

## edit user model

validations & virtual password field

Note:
`field :password, :string, virtual: true`

```
@required_fields ~w(email)a
@optional_fields ~w()a

def changeset(struct, params \\ %{}) do
  struct
  |> cast(params, @required_fields ++ @optional_fields)
  |> validate_required(@required_fields)
end
```

---

## user controller

Note:
```
defmodule LoginApp.UserController do
  use LoginApp.Web, :controller

  alias LoginApp.User

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render conn, "show.html", user: user
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
  end
end
```
---

## router

`resources "/users", UserController, only: [:show, :new, :create]`

---

## view & templates

Note:
```
defmodule LoginApp.UserView do
  use LoginApp.Web, :view
end
```

```
<h1>User Registration</h1>
<%= form_for @changeset, user_path(@conn, :create), fn f -> %>
  <%= if @changeset.action do %>
    <div class="alert alert-danger">
      <p>There are some errors</p>
    </div>
  <% end %>
  <div class="form-group">
    <%= text_input f, :email, placeholder: "Email",
                              class: "form-control" %>
    <%= error_tag f, :email %>
  </div>
  <div class="form-group">
    <%= password_input f, :password, placeholder: "Password",
                                     class: "form-control" %>
    <%= error_tag f, :password %>
  </div>
  <%= submit "Create User", class: "btn btn-primary" %>
<% end %>
```

```
# ../layout/app.html.eex
<ul class="nav nav-pills pull-right">
  <li>
    <%= link "Register", to: user_path(@conn, :new) %>
  </li>
</ul>
```
---

## creating users

add `comeonin` to list of dependencies in `mix.exs`
+ `mix deps.get` (like `bundle`)

create registration changeset in user model

implement `:create` action in user controller

**users are now creatable**

Note:
```
# mix.exs
def application do
  [mod: {LoginApp, []},
   applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext, :phoenix_ecto, :postgrex, :comeonin]]
end
defp deps do
    [{:phoenix, "~> 1.2.0"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},
     {:comeonin, "~> 2.5"}]
end
```

```
def registration_changeset(struct, params) do
  struct
  |> changeset(params)
  |> cast(params, ~w(password)a, [])
  |> validate_length(:password, min: 6, max: 100)
  |> hash_password
end
defp hash_password(changeset) do
  case changeset do
    %Ecto.Changeset{valid?: true,
                    changes: %{password: password}} ->
      put_change(changeset,
                  :password_digest,
                  Comeonin.Bcrypt.hashpwsalt(password))
    _ ->
      changeset
  end
end
```

```
plug :scrub_params, "user" when action in [:create]

def create(conn, %{"user" => user_params}) do
  changeset = %User{} |> User.registration_changeset(user_params)
  case Repo.insert(changeset) do
    {:ok, user} ->
      conn
      |> put_flash(:info, "#{user.email} created!")
      |> redirect(to: user_path(conn, :show, user))
    {:error, changeset} ->
      render(conn, "new.html", changeset: changeset)
   end
 end
 ```

---

## creating sessions

session routes

session controller

session view & template

Note:
`resources "/sessions", SessionController, only: [:new, :create, :delete]`

```
defmodule LoginApp.SessionController do
  use LoginApp.Web, :controller
  plug :scrub_params, "session" when action in [:create]
  def new(conn, _) do
    render conn, "new.html"
  end
  def create(conn, %{"session" => %{"email" => email,
                                    "password" => password}}) do
  end
  def delete(conn, _) do
  end
end
```

```
# web/views/session_view.ex
defmodule LoginApp.SessionView do
  use LoginApp.Web, :view
end
```

```
# web/templates/session/new.html.eex
<h1>Sign in</h1>
<%= form_for @conn, session_path(@conn, :create),
                                          [as: :session], fn f -> %>
  <div class="form-group">
    <%= text_input f, :email, placeholder: "Email",
                              class: "form-control" %>
  </div>
  <div class="form-group">
    <%= password_input f, :password, placeholder: "Password",
                                     class: "form-control" %>
  </div>
  <%= submit "Sign in", class: "btn btn-primary" %>
<% end %>
```

```
# web/templates/layout/app.html.eex
<li>
  <%= link "Sign in", to: session_path(@conn, :new) %>
</li>
```

---

## creating sessions part 2

add `:guardian` as a dependency to handle sessions (via JWTs?)
+ have to add a serializer module to `web/auth`

session controller create
+ find user by email, see if the pw matches, `Guardian.Plug.sign_in(user)`

Note:
```
# config.exs
config :guardian, Guardian,
 issuer: "LoginApp.#{Mix.env}",
 ttl: {30, :days},
 verify_issuer: true,
 serializer: LoginApp.GuardianSerializer,
 secret_key: to_string(Mix.env) <> "SuPerseCret_aBraCadabrA"
```

```
# web/auth/guardian_serializer.ex
defmodule LoginApp.GuardianSerializer do
  @behaviour Guardian.Serializer
  alias LoginApp.Repo
  alias LoginApp.User
  def for_token(user = %User{}), do: { :ok, "User:#{user.id}" }
  def for_token(_), do: { :error, "Unknown resource type" }
  def from_token("User:" <> id), do: { :ok, Repo.get(User, id) }
  def from_token(_), do: { :error, "Unknown resource type" }
end
```

```
# web/controllers/session_controller.ex
import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
alias SimpleAuth.User
# ...
def create(conn, %{"session" => %{"email" => email,
                                  "password" => password}}) do
  # try to get user by unique email from DB
  user = Repo.get_by(User, email: email)
  # examine the result
  result = cond do
    # if user was found and provided password digest equals to stored
    # digest
    user && checkpw(password, user.password_digest) ->
      {:ok, login(conn, user)}
    # else if we just found the use
    user ->
      {:error, :unauthorized, conn}
    # otherwise
    true ->
      # simulate check password hash timing
      dummy_checkpw
      {:error, :not_found, conn}
  end
  case result do
    {:ok, conn} ->
      conn
      |> put_flash(:info, "You’re now logged in!")
      |> redirect(to: page_path(conn, :index))
    {:error, _reason, conn} ->
      conn
      |> put_flash(:error, "Invalid email/password combination")
      |> render("new.html")
  end
end
defp login(conn, user) do
  conn
  |> Guardian.Plug.sign_in(user)
end
```

---

## current_user

add a current_user helper module and a `:with_session` pipeline

Note:
```
# web/auth/current_user.ex
defmodule SimpleAuth.CurrentUser do
  import Plug.Conn
  import Guardian.Plug
  def init(opts), do: opts
  def call(conn, _opts) do
    current_user = current_resource(conn)
    assign(conn, :current_user, current_user)
  end
end
```

```
# web/router.ex
pipeline :with_session do
  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.LoadResource
  plug SimpleAuth.CurrentUser
end
```

`pipe_through [:browser, :with_session]`

---

## deleting sessions

`Guardian.Plug.sign_out(conn)`; redirect

Note:
```
def delete(conn, _) do
  conn
  |> logout
  |> put_flash(:info, "See you later!")
  |> redirect(to: page_path(conn, :index))
end
defp logout(conn) do
  Guardian.Plug.sign_out(conn)
end
```

---

## refactor view

display "log out" if user is logged in, display links otherwise

Note:
```
<ul class="nav nav-pills pull-right">
  <%= if @current_user do %>
    <li><%= @current_user.email %> (<%= @current_user.id %>)</li>
    <li>
      <%= link "Sign out", to: session_path(@conn, :delete,
                                            @current_user),
                           method: "delete" %>
    </li>
  <% else %>
    <li><%= link "Register", to: user_path(@conn, :new) %></li>
    <li><%= link "Sign in", to: session_path(@conn, :new) %></li>
  <% end %>
</ul>
```

---

## refactor auth functionality

refactor out common auth functionality into a helper module

this allows us to log users in when they sign up

Note:
```
# web/auth/auth.ex
defmodule LoginApp.Auth do
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  alias LoginApp.User
  alias LoginApp.Repo
  def login(conn, user) do
    conn
    |> Guardian.Plug.sign_in(user)
  end
  def login_by_email_and_pass(conn, email, given_pass) do
    user = Repo.get_by(User, email: email)
    cond do
      user && checkpw(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw
        {:error, :not_found, conn}
    end
  end
  def logout(conn) do
    Guardian.Plug.sign_out(conn)
  end
end
```
```
# web/controllers/session_controller.ex
defmodule LoginApp.SessionController do
  use LoginApp.Web, :controller
  plug :scrub_params, "session" when action in ~w(create)a
  def new(conn, _) do
    render conn, "new.html"
  end
  def create(conn, %{"session" => %{"email" => email,
                                    "password" => password}}) do
    case LoginApp.Auth.login_by_email_and_pass(conn, email,
                                                 password) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "You’re now signed in!")
        |> redirect(to: page_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> render("new.html")
     end
  end
  def delete(conn, _) do
    conn
    |> LoginApp.Auth.logout
    |> put_flash(:info, "See you later!")
    |> redirect(to: page_path(conn, :index))
  end
end
```
```
# web/controllers/user_controller.ex
def create(conn, %{"user" => user_params}) do
  changeset = %User{} |> User.registration_changeset(user_params)
  case Repo.insert(changeset) do
    {:ok, user} ->
      conn
      |> SimpleAuth.Auth.login(user)
      |> put_flash(:info, "#{user.name} created!")
      |> redirect(to: user_path(conn, :show, user))
    {:error, changeset} ->
      render(conn, "new.html", changeset: changeset)
  end
end
```