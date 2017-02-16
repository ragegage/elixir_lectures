defmodule Intro do
  def madlib(verb, adj, noun) do
    "We shall #{verb} the #{adj} #{noun}"
  end

  def is_substring(search_string, sub_string) do
    [_|t] = String.split search_string, sub_string
    t == []
  end

  def fizz_buzz(list) do
    Enum.map(list, fn el -> whichfizz(rem(el, 3), rem(el, 5), el)  end)
  end

  defp whichfizz(0, 0, _) do
    "FizzBuzz"
  end
  defp whichfizz(0, _, _) do
    "Fizz"
  end
  defp whichfizz(_, 0, _) do
    "Buzz"
  end
  defp whichfizz(_, _, n) do
    n
  end
  
  def is_prime?(num) do
    is_prime? num, 2
  end

  defp is_prime?(num, _) when num < 2 do
    false
  end
  defp is_prime?(num, factor) when num <= factor do
    true
  end
  defp is_prime?(num, factor) when rem(num, factor) == 0 do
    false
  end
  defp is_prime?(num, factor) when num > factor do
    is_prime? num, factor + 1
  end

  def sum_n_primes(n) do
    1..100_000 |> Stream.filter(&(Intro.is_prime?(&1))) |> Enum.take(n) |> Enum.sum
  end
end


IO.puts Intro.madlib "crush", "first", "assessment"
IO.puts Intro.is_substring "time to program", "time"
IO.puts Intro.is_substring "Jump for joy", "joys"
IO.inspect Intro.fizz_buzz [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
IO.puts Intro.is_prime? 2 #=> true
IO.puts Intro.is_prime? 10 #=> false
IO.puts Intro.is_prime? 41 #=> true
IO.puts Intro.sum_n_primes 4 #=> 17