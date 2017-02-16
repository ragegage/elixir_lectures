"hello #{1+1}" # prints "hello 2"

"he" <> rest = "hello"

String.length "test"

String.upcase "test"

add = fn a, b -> a + b end
add.(1, 2) # returns 3

(fn n -> n * n end).(6) # 36

[1,2,3] ++ [4,5,6]

[1,2,3] -- [1]

[h | rest] = [1,2,3]

hd [1,2,3]

tl [1,2,3]

[104, 101, 108, 108, 111] # 'hello'

# q: what are tuples?
tuple = {1, :test}

elem(tuple, 0) # 1

put elem tuple, 1, "test" # {1, "test"}


{a, b, c} = {1, :test, "hello"}
a # 1
{:ok, result} = {:ok, "went well"}
result # "went well"
{:ok, result} = {:error, "broke"} # ** (MatchError) no match of right hand side value: {:error, :oops}
a = :ok
{^a, result} = {:ok, 13}
result # 13


map = %{:a => 1, 2 => :b}
map[:a] # 1
%{} = %{a: => 1, 2 => :b}
%{:a => a} = %{:a => 1, 2 => :b}
a # 1

n = 1
map = %{n => :one}
map[1] # :one

map = %{a: 1, b: 2} # requires an all-atom key set
map.a # 1

users = [
  john: %{name: "John", age: 27, languages: ["Erlang", "Ruby", "Elixir"]},
  mary: %{name: "Mary", age: 29, languages: ["Elixir", "F#", "Clojure"]}
]
users[:john].age # 27
users = put_in users[:john].age, 31
users[:john].age # 31


defmodule Math do
    def sum(a, b) do
        a + b
    end
end
Math.sum(1, 2) # 3

fun = &(&1 + &2)
fun.(6, 7) # 13

fun = fn x, y -> x + y end
fun.(4, 3) # 7


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

defmodule Math do
  def sum_list([head | tail], accumulator) do
    sum_list(tail, head + accumulator)
  end

  def sum_list([], accumulator) do
    accumulator
  end
end
IO.puts Math.sum_list([1, 2, 3], 0)

defmodule Math do
  def double_each([head | tail]) do
    [head * 2 | double_each(tail)]
  end

  def double_each([]) do
    []
  end
end
Math.double_each([1, 2, 3])

odd? = &(rem(&1, 2) != 0)
1..100_000 |> Enum.map(&(&1 * 3)) |> Enum.filter(odd?) |> Enum.sum

Enum.take(Stream.cycle([1,2,3]),10)
Enum.take(Stream.cycle([1,2,3]),10) |> Enum.filter(odd?)