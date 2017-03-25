# no mutations, no methods
a = {1,3,5}
put_elem(a, 2, 6)

# =
b = {:ok, 5}
{:ok, c} = {:ok, 5}
{:error, d} = {:ok, 5}

"he" <> rest = "hello"
"he" <> rest = "goodbye"

[h | t] = [1,2,3]

# enumerating, function heads
defmodule Math do
  def double_each([head | tail]) do
    [head * 2 | double_each(tail)]
  end

  def double_each([]) do
    []
  end
end
Math.double_each [1,2,3]

# guards
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

# anonymous functions
add = fn a, b -> a + b end
add.(1, 2)

(fn n -> n * n end).(6)

multi_heads = fn
  1 -> "one"
  2 -> "two"
  _ -> "not one or two"
end

multi_heads.(1) # => "one"
multi_heads.(2) # => "two"
multi_heads.(3) # => "not one or two"

# |>
defmodule ASDF do
  def asdf, do: [1,2,3]
end
ASDF.asdf
ASDF.asdf |> Math.double_each
