# Range

defmodule MyRange do
  def create(s, e) when e >= s do
    (s..e)
    |> Enum.to_list
  end
  def create(_, _) do
    "invalid start and endpoints"
  end
end

# FizzBuzz

defmodule FizzBuzz do
  def fizz_buzz(list) do
    Enum.map(list, fn el -> whichfizz(rem(el, 3), rem(el, 5), el)  end)
  end

  defp whichfizz(0, 0, _), do: "FizzBuzz"
  defp whichfizz(0, _, _), do: "Fizz"
  defp whichfizz(_, 0, _), do: "Buzz"
  defp whichfizz(_, _, n), do: n
end

defmodule MyList do
# Sum list elements
  def sum(list) do
    list
    |> Enum.reduce(fn (el, acc) -> acc + el end)
  end

# my_reduce
  def my_reduce([h | t], acc, func) do
    my_reduce(t, func.(h, acc), func)
  end
  def my_reduce([], acc, _), do: acc

# my_select
  def my_select(list, func) do
    my_select(list, func, [])
  end
  defp my_select([h | t], func, new_list) do
    if func.(h) do
      my_select(t, func, new_list ++ [h])
    else
      my_select(t, func, new_list)
    end
  end
  defp my_select([], _, new_list), do: new_list

# my_any?
  def my_any?([h | t], func) do
    if func.(h) do
      true
    else
      my_any?(t, func)
    end
  end
  def my_any?([], _), do: false

# my_map
  def my_map(list, func) do
    my_map(list, func, [])
  end
  defp my_map([h | t], func, new_list) do
    my_map(t, func, new_list ++ [func.(h)])
  end
  defp my_map([], _, new_list), do: new_list

# my_rotate
  def my_rotate([h | t], amount) when amount > 0 do
    my_rotate(t ++ [h], amount - 1)
  end
  def my_rotate(list, amount) when amount < 0 do
    my_rotate(Enum.take(list, -1) ++ Enum.drop(list, -1), amount + 1)
  end
  def my_rotate(list, amount) when amount == 0 do
    list
  end

# Remove duplicates from list
  def my_uniq(list) do
    list
    |> MapSet.new
    |> Enum.to_list
  end

# my_flatten
  def my_flatten(list), do: my_flatten(list, [])
  defp my_flatten([h | t], next) when is_list(h) do
    my_flatten(t, next ++ my_flatten(h, []))
  end
  defp my_flatten([h | t], next) do
    my_flatten(t, next ++ [h])
  end
  defp my_flatten([], next), do: next

# my_zip
  def my_zip(list1, list2), do: my_zip(list1, list2, [])
  defp my_zip([h1 | t1], [h2 | t2], result) do
    my_zip(t1, t2, result ++ [[h1, h2]])
  end
  defp my_zip([h1 | t1], [], result) do
    my_zip(t1, [], result ++ [[h1, nil]])
  end
  defp my_zip([], _, result), do: result
end

# Substrings
defmodule Substrings do
  def substrings(string) do
    length = String.length string
    walk_up(string, 0, length, [""])
  end
  defp walk_up(_, _, len, list) when len == 0, do: list
  defp walk_up(string, idx, len, list) when idx <= len do
    walk_up(string, idx + 1, len, [String.slice(string, 0, idx)] ++ list)
  end
  defp walk_up(string, _, len, list) do
    new_string = String.split(string, "") 
      |> Enum.drop(1)
      |> IO.inspect
      |> Enum.join
    walk_up(new_string, 0, len - 1, list)
  end
end

# Mergesort
defmodule Mergesort do
  def sort(list) when length(list) < 2 do
    list
  end
  def sort(list) do
    half = length(list)/2 |> trunc
    merge(sort(Enum.take(list, half)), sort(Enum.drop(list, half)), [])
  end

  defp merge([h1 | t1], [h2 | t2], merged) when h1 <= h2 do
    merge(t1, [h2 | t2], merged ++ [h1])
  end
  defp merge([h1 | t1], [h2 | t2], merged) when h2 < h1 do
    merge([h1 | t1], t2, merged ++ [h2])
  end
  defp merge([], list2, merged), do: merged ++ list2
  defp merge(list1, [], merged), do: merged ++ list1
  defp merge([], [], merged), do: merged
end

# Curry:
defmodule Curry do

  def curry(fun) do
    {_, arity} = :erlang.fun_info(fun, :arity)
    curry(fun, arity, [])
  end

  def curry(fun, 0, arguments) do
    apply(fun, Enum.reverse arguments)
  end

  def curry(fun, arity, arguments) do
    fn arg -> curry(fun, arity - 1, [arg | arguments]) end
  end

end
