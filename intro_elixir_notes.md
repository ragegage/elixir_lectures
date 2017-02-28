
# Intro to Elixir

[main source](http://elixir-lang.org/getting-started/introduction.html)

---

erlang:
concurrency
fault tolerance
distribution
high availability

Erlang is a component of Ericsson, which has about a 35 percent global market share in the wireless network infrastructure.

Erlang was WhatsApp's "secret sauce" - https://blog.whatsapp.com/170/ONE-MILLION%21?p=170

[intro to erlang](http://learnyousomeerlang.com/introduction)
[pros and cons of erlang](http://learnyousomeerlang.com/introduction#kool-aid)
[concurrency](http://learnyousomeerlang.com/the-hitchhikers-guide-to-concurrency)

---

erlang is:
compiled
immutable state
functional
processes
message-passing concurrency
process monitoring with automatic restarts
distributed computing

---

erlang compiles to code that runs on the BEAM VM; elixir compiles to code that the BEAM VM can run as well.

things elixir implements that erlang doesn't:
macros
polymorphism

Elixir was created by José Valim, a Rails core team member, in 2011.

---

**elixir:**
division always returns a float; use the div method to do integer division
`10 / 3 # float division -> 3.3333333333333335`
`div 10, 3 # integer division -> 3`
`round 3.55 # rounds to 4`
`trunc 3.55 # truncates to 3`

functions have a name and an arity (number of arguments). can look up documentation for a given method using `h method_name/arity` (e.g., `h is_integer/1`

is_boolean; is_integer; &c.

---

*atoms* are elixirs name for symbols in ruby (e.g., `:atom`)

---

string interpolation is the same as ruby (e.g., `"hello #{1+1}" # prints "hello 2"`)
get length of string by running `String.length "string"`; `String.upcase`; &c.
string concatenation is done with the `<>` operator.

---

anonymous functions are defined similarly to ruby functions but with the words `fn` and `end` delimiting the function (e.g., `add = fn a, b -> a + b end`)
to call an anonymous function, you put a `.` between the name and the list of arguments => `add.(1, 2) # returns 3`
these anonymous functions are closures.
you can define a function and invoke it on the same line like this: `(fn r -> IO.puts r end).(6) # prints "6" and returns :ok`

---

lists are defined using square brackets. `++` concatenates two lists; `--` subtracts the second list from the first. `hd list` gets the first item of the list; `tl list` gets the tail of the list (the rest of the list). lists of ASCII character codes get turned into single string quotes (e.g., `[104, 101, 108, 108, 111] # 'hello'`).
lists are stored in memory as linked lists; prepending elements is O(1) but finding the length is O(n).

---

tuples are defined using curly brackets (e.g., `tuple = {1, :test}`; you can index into them using elem: `elem tuple, 0 # 1`; you can change the contents of a tuple using `put_elem tuple, pos, element` (e.g., `put elem tuple, 1, 2 # {1, 2}`). because data types are immutable in elixir, the original tuple isn't changed.
tuples are stored contiguously in memory; finding the length is O(1) but changing elements is O(n) because it requires copying the tuple's entire contents to a new tuple.

Note:
"tuple" means a finite ordered list of elements

---

in general, `size` functions take constant time and `length` functions take linear time.

---

boolean operators are `or`, `and`, and `not`. these operations only take boolean values. the `&&`, `||`, and `!` operators can take multiple different types of values.
other operators include `==`, `===`, `!=`, `!==`, `<`, `>`, `<=`, and `>=`. the difference between `==` and `===` is that the former is less strict comparing integers and floats.
elixir data types are ordered `number < atom < reference < function < port < pid < tuple < map < list < bitstring`

---

elixir's `=` operator allows relatively sophisticated pattern matching
```
{a, b, c} = {1, :test, "hello"}
a # 1
```
```
{:ok, result} = {:ok, 13}
result # 13
```
```
{:ok, result} = {:error, 5} # ** (MatchError) no match of right hand side value: {:error, :oops}
```
```
[head | tail] = [1,2,3]
head # 1
tail # [2,3]
```
you can use the `^` operator to pattern match against a variable's value:
```
a = :ok
{^a, result} = {:ok, 13}
result # 13
```
if you don't care about a value in a pattern, you can use `_` to fill that space.

---

case statements allow you to compare a value against patterns. you can use the `_` as a default that will match every pattern.
you can also put extra conditions into case statements.
```
a = {1,2,3}
case a do
{1,2,4} -> "won't get printed"
{1,x,3} when x > 0 -> "will get printed because the pattern matches and the extra clause also matches"
_ -> "default will get printed if none of the other patterns match"
```

---

elixir does have `if` and `unless` statements that can be combined with an `else` statement; these statements are macros rather than being language constructs.
the equivalent of `if...else if` in elixir is the `cond` statement, which returns the value associated with the first statement that returns true.
```
cond do
2 + 2 == 5 -> "won't get returned"
true -> "will get returned"
end # "will get returned"
```

`do / end` blocks are syntactic sugar for list syntax: `if false, do: :this, else: :that`

---

char lists:
you can see how many bytes a char list needs to encode its values using the `byte_size/1` function.
binaries:
you can define a binary (a sequence of bytes) using the following syntax: `<<1, 23, 14>>`. string concatenation in elixir is actually binary concatenation: `<<1, 2>> <> <<3>> # <<1, 2, 3>>`
you can also pattern match with binaries: 
```
<<1, 2, x>> = <<1, 2, 3>>
x # 3
```
and the string concatenation operator:
```
"he" <> rest = "hello"
rest # "llo"
```
To recap, a string is a UTF-8 encoded binary and a binary is a bitstring where the number of bits is divisible by 8.

---

keyword lists:

a list of 2-item tuples, where the first item in each tuple is an atom.

`[{:a, 1}, {:b, 2}] == [a: 1, b:2]`

`[a:1] ++ [b:2] # [a:1, b:2]`

```
list = [a: 1, a: 2]
list[:a] # 1
```

keys must be atoms, keys are ordered, and keys can be given more than once

keyword lists are the default mechanism for passing options to functions

---

Maps are used for storing key-value pairs.

Map literals look like: `map = %{:a => 1, 2 => :b}`

maps allow any value as a key

maps' keys are not ordered

Maps can be used in pattern matching:
```
%{} = %{a: => 1, 2 => :b}
%{:a => a} = %{:a => 1, 2 => :b}
a # 1
```

variables can be used for map keys:
```
n = 1
map = %{n => :one}
map[1] # :one
```

if every key in a map is an atom, you can use json-like shorthand:
```
map = %{a: 1, b: 2}
map.a # 1
```

---

Nested data structures

```
users = [
  john: %{name: "John", age: 27, languages: ["Erlang", "Ruby", "Elixir"]},
  mary: %{name: "Mary", age: 29, languages: ["Elixir", "F#", "Clojure"]}
]
users[:john].age # 27
put_in users[:john].age, 31
users[:john].age # 31
```

---

Modules

```
defmodule Math do
    def sum(a, b) do
        a + b
    end
end
Math.sum(1, 2) # 3
```

you can compile modules using the `elixirc` command in the terminal (e.g., `elixirc math.ex`)

you can also compile and run `.exs` files without creating a `.beam` file like so: `elixir math.exs`

---

inside modules, `def` creates public functions while `defp` creates private functions

---

functions can also have guards:

```
defmodule Math do
  def zero?(0) do
    true
  end

  def zero?(x) when is_integer(x) do
    false
  end
end
```

Note:
test with:
```
IO.puts Math.zero?(0)         #=> true
IO.puts Math.zero?(1)         #=> false
IO.puts Math.zero?([1, 2, 3]) #=> ** (FunctionClauseError)
IO.puts Math.zero?(0.0)       #=> ** (FunctionClauseError)
```

---

you can use `name/arity` notation to retrieve a function:

```
fun = &Math.zero?/1
is_function(fun)
fun.(0) # true
```

Note:
remember that `fun` is an anonymous function

---

Capture syntax

allows functions to be assigned to variables:

```
&is_function/1
(&is_function/1).(fun) # true

fun = &(&1 + 1)
fun.(8) # 9

fun = &(&1 + &2)
fun.(6, 7) # 13

fun = fn x, y -> x + y end
fun.(4, 3) # 7
```

---

You can add default arguments to named functions using `\\`:

```
defmodule Concat do
  def join(a, b, sep \\ " ") do
    a <> sep <> b
  end
end

IO.puts Concat.join("Hello", "world")      # Hello world
IO.puts Concat.join("Hello", "world", "_") # Hello_world
```

If a function has multiple clauses and default values, you must create a function head with no body to declare the defaults:
```
defmodule Concat do
  def join(a, b \\ nil, sep \\ " ")

  def join(a, b, _sep) when is_nil(b) do
    a
  end

  def join(a, b, sep) do
    a <> sep <> b
  end
end
```

---

no `for` loops in elixir - only recursion!

but in general, use the `Enum` module, which has most of the normal functions in it (`reduce`, `map`, &c.)

Note:
demo the following:
```
defmodule Recursion do
  def print_multiple_times(msg, n) when n <= 1 do
    IO.puts msg
  end

  def print_multiple_times(msg, n) do
    IO.puts msg
    print_multiple_times(msg, n - 1)
  end
end

Recursion.print_multiple_times("Hello!", 3)
```
```
defmodule Math do
  def sum_list([head | tail], accumulator) do
    sum_list(tail, head + accumulator)
  end

  def sum_list([], accumulator) do
    accumulator
  end
end

IO.puts Math.sum_list([1, 2, 3], 0)
```
```
defmodule Math do
  def double_each([head | tail]) do
    [head * 2 | double_each(tail)]
  end

  def double_each([]) do
    []
  end
end
```
---

`Enumerable` is similar to ruby's: the functions work with any data type that implements its protocol.

you can pipe the results of a function directly into another function using `|>`:
```
1..100_000 |> Enum.map(&(&1 * 3)) |> Enum.filter(odd?) |> Enum.sum
```

---

While `Enumerable` is eager, `Stream` is lazy:
```
1..100_000 |> Stream.map(&(&1 * 3)) |> Stream.filter(odd?) |> Enum.sum
```

`Stream.cycle/1` creates a stream that cycles an enumerable indefinitely:
```
Enum.take(Stream.cycle([1,2,3]),10)
```

`Stream.unfold/2` and `Stream.resource/3` are also interesting functions

---


IO

for stdio: `IO.puts`, `IO.gets`

for files: `IO.binread/2`, `IO.binwrite/2`
`File`: `File.open`, `File.read`, `File.close`, `File.rm`, `File.mkdir`, `File.mkdir_p`, `File.cp_r`, `File.rm_rf`
  + two versions:
    + "regular" - returns a tuple; allows pattern matching
    + "bang" (!) - returns the contents or throws an error

if you don't want to handle error outcomes (i.e., if you expect the file to be there), use `File.read!/1`

---

`Path`: 
+ `Path.join("foo", "bar") # "foo/bar"`
+ `Path.expand("~/hello") # /Users/ragegage/hello`

---

IO takes place in a process. You can mock the IO process for reading a string
using the StringIO module

---

```
# Alias the module so it can be called as Bar instead of Foo.Bar
alias Foo.Bar, as: Bar
alias Foo.Bar # does the same thing

# Ensure the module is compiled and available (usually for macros)
require Foo

# Import functions from Foo so they can be called without the `Foo.` prefix
import Foo
# can also run import List, only: [duplicate: 2] to only load the duplicate/2
# function

# ^ all lexically scoped

# Invokes the custom code defined in Foo as an extension point
use Foo

# ^ usually used in testing?
```

Note: 
modules defined in Elixir are defined inside an `Elixir` namespace that
you can omit

you can also define nested modules:
```
defmodule Foo do
  defmodule Bar do
  end
end
defmodule Elixir.Fizz.Buzz.Baz do
end
```
---

Documentation

```
defmodule Math do
  @moduledoc """
  Provides math-related functions.

  ## Examples

      iex> Math.sum(1, 2)
      3

  """

  @doc """
  Calculates the sum of two numbers.
  """
  def sum(a, b), do: a + b
end
```

`h Math # docs for Math module`
`h Math.sum # docs for Math's sum function`

---

Other Attributes

modules can have arbitrary attributes, defined using the syntax `@attribute
value` and accessible inside the module using the syntax `@attribute`

---

Structs

structs take the name of the module they're defined within

you can access and update fields using the same syntax as maps

structs have a field `__struct__` that holds the name of the struct

you can't iterate or use `[:field]` syntax on structs, but you can use the Map module's functions (`put/2`, `merge/2`, `keys/1`)

if you don't specify a default value for a key, `nil` is assumed: `defstruct [:model, :make]`

`@enforce_keys [:key]` will make your struct throw an error if that key/value
pair is not specified when creating a struct of that type

Note:
```
defmodule User do
  defstruct name: "John", age: 27
end

john = %User{} # %User{age: 27, name: "John"}
john.name # "John"
%User{name: "Meg"} # %User{age: 27, name: "Meg"}
meg = %{john | name: "Meg"} # %User{age: 27, name: "Meg"}
%User{oops: :field} # ** (KeyError) key :oops not found in: %User{age: 27, name: "John"}
%User{name: name} = john
name # "John"
john.__struct__
```

---

Protocols

protocols are a way to achieve polymorphism by defining a protocol and then
defining implementations for multiple data types

you also have to implement protocols for each struct

```
Size.size("foo")
Size.size({:ok, "hello"})
Size.size(%{label: "labeled"})
```

Note:
```
defprotocol Size do
  @doc "Calculates the size of a data structure"
  def size(data)
end

defimpl Size, for: BitString do
  def size(string), do: byte_size(string)
end
defimpl Size, for: Map do
  def size(map), do: byte_size(map)
end
defimpl Size, for: Tuple do
  def size(tuple), do: byte_size(tuple)
end

# for a struct:
defmodule User do
  defstruct [:name, :age]
end

defimpl Size, for: User do
  def size(_user), do: 2
end
```
---

if we set `@fallback_to_any true` in a protocol, we can write a generic
implementation that matches all types:
```
defimpl Size, for: Any do
  def size(_), do: 0
end
```
this will keep this function from throwing an error if the protocol has not
been implemented for that type

alternatively, to be more explicit about the size implementation for a new
type, we can add `@derive [Size]` to a module. in this case, we still need the
implementation for any type (`defimpl Size, for: Any`)

---

built-in protocols:

+ `Enum` module (works with data structures that implement the `Enumerable`
protocol -> `map`, `reduce`, &c.)
+ `String.Chars` (`to_string` function)
+ `Inspect` (`inspect` function)

Note:
protocol consolidation -> if we use Mix to compile our code, we can know that
all modules (including protocols and implementations) have been defined

---

Comprehensions:

`for n <- [1,2,3,4], do: n * n # [1,4,9,16]`

+ generators (generate values to be used - can be any enumerable: ranges, pattern matching; can be a list of generators)
+ filters (if filter returns `false` or `nil` for an element, it gets discarded)
+ collectables

Note:
```
# finds pythagorean triples that add up to n
defmodule Triple do
  def pythagorean(n) when n > 0 do
    for a <- 1..n-2,
        b <- a+1..n-1,
        c <- b+1..n,
        a + b + c == n,
        a*a + b*b == c*c,
        do: {a, b, c}
  end
end

pixels = <<213, 45, 132, 64, 76, 32, 76, 0, 0, 234, 32, 15>>
# converts list of pixels into rgb tuples
for <<r::8, g::8, b::8 <- pixels>>, do: {r, g, b}
```

---

`:into` - can pass any structure that implements the `Collectable` protocol

transforms the values in a map without changing the keys:
`for {key, val} <- %{"a" => 1, "b" => 2}, into: %{}, do: {key, val * val}`

prints back every input in STDIO upcased
```
stream = IO.stream(:stdio, :line)
for line <- stream, into: stream do
  String.upcase(line) <> "\n"
end
```

---

Built-in Sigils

+ `~r` -> regex
+ `~s` -> string
+ `~c` -> char list (single quotes)
+ `~w` -> word lists (lists of strings)
  + `c` -> char lists
  + `s` -> strings
  + `a` -> atoms

uppercase sigil characters don't allow escape characters or interpolation

creates a regex that matches "*foo*" and "*bar*"
`regex = ~r/foo|bar/`
creates a case-insensitive version
`regex = ~r/foo|bar/i`
creates a regex that matches "https://" without escape characters
`regex = ~r(^https?://)`

creates a string with double quotes in it
`~s(this is a string with "double" quotes, not 'single' ones)`

creates a char list with single quotes in it
`~c(this is a char list containing 'single quotes')`

creates a word list filled with atoms
`~w(these are atoms) # [:these, :are, :atoms]`

---

Defining new sigils

```
defmodule MySigils do
  def sigil_i(string, []), do: String.to_integer(string)
  def sigil_i(string, [?n]), do: -String.to_integer(string)
end

~i(13) # 13
~i/13/n # -13
```

---

Errors

`raise "message"`
`raise ArgumentError, message: "bad argument"`

Rescue

```
try do
  raise RuntimeError, message: "oops"
rescue
  e in RuntimeError -> e
end
```

^ not commonly done - instead:
```
case File.read "hello" do
  {:ok, body}      -> IO.puts "Success: #{body}"
  {:error, reason} -> IO.puts "Error: #{reason}"
end
```

can also write `try/after`:
```
try do
  IO.write file, "words words"
  raise "something went wrong"
after
  File.close(file)
end
```
^ not optimal; if a linked process exits, then this process will also exit and
the `after` clause will not get run. in practice, you don't have to do this
stuff for IO because files in Elixir are linked to the current process by
default and get closed if the process crashes.

---

Throw / Catch

```
try do
  Enum.each -50..50, fn(x) ->
    if rem(x, 13) == 0, do: throw(x)
  end
  "Got nothing"
catch
  x -> "Got #{x}"
end
```

---

Exits

when a process dies, it sends an `exit` signal (you can also send them manually
a lá `spawn_link fn -> exit(1) end`)

process supervisors listen for `exit` signals from their subordinate processes
and, on the occasion that they get them, restart the process that failed.

---

Additional topics:

+ typespecs (`@spec add(number, number) :: number`)
  + can be helpful for documentation
  + can also be used for static code analysis
+ [Erlang libraries](http://elixir-lang.org/getting-started/erlang-libraries.html)
  + crypto
  + digraph
  + ETS (Erlang Term Storage)
  + queue
  + rand
+ [concurrency in Erlang](http://www.erlang.org/course/concurrent-programming)

---

Behaviours (note the "u")

defines a set of functions that need to be implemented by everything adopting
this behaviour
```
defmodule Parser do
  @callback parse(String.t) :: any
  @callback extensions() :: [String.t]
end

defmodule JSONParser do
  @behaviour Parser

  def parse(str), do: # ... parse JSON
  def extensions, do: ["json"]
end
```

---