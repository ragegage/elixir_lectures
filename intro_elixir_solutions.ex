Range

FizzBuzz

Sum list elements

my_reduce

my_select

my_any

my_map

my_rotate

Remove duplicates from list

Substrings

my_flatten

my_zip

Binary Search

Mergesort

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

