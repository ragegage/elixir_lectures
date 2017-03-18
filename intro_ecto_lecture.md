### schemas
#### (models)

handled by **Ecto**

+ migrations (`mix ecto.gen.migration create_dogs`) (like rails)
+ schemas are the equivalent of rails models
  
+ changesets are the equivalent of rails validations

Note:
migrate using `mix ecto.migrate` / `mix ecto.rollback`

schemas structure the table's information
+ `p = %APP_NAME.SCHEMA_NAME{}` is the equivalent of `u = User.new`
  + `%{p | age: 15}` is the equivalent of `u.age = 15`
+ `APP_NAME.Repo.insert(p)`

`changeset = APP_NAME.SCHEMA_NAME.changeset(OLD_VALUE, CHANGES)`
+ `changeset.errors` is like `u.errors` after you call `u.valid?`
+ `changeset.valid?` is like `u.valid?`
+ `APP_NAME.Repo.insert(changeset)`
  + returns `{:error, changeset}` if the insert failed
+ `APP_NAME.Repo.insert!(changeset)`
  + errors out if the insert failed


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

can chain queries (just like rails)

```
APP_NAME.SCHEMA_NAME |> Ecto.Query.first |> APP_NAME.Repo.one
APP_NAME.SCHEMA_NAME |> APP_NAME.Repo.all
APP_NAME.SCHEMA_NAME |> APP_NAME.Repo.get(^id)
APP_NAME.SCHEMA_NAME |> APP_NAME.Repo.get_by(first_name: "Gage")
```

Note:
the first example is equivalent to `Person.first` in rails
the second, `Person.all`
the third, `Person.find(:id)`
thr fourth, `Person.find_by(first_name: "Gage")`
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
