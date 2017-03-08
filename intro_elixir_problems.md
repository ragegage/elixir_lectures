Introductory Elixir Problems

1. MyRange
```
MyRange.create(4, 9)
# => [4, 5, 6, 7, 8, 9]
```
1. FizzBuzz
```
FizzBuzz.fizz_buzz((1..20))
# => [1, 2, "Fizz", 4, "Buzz", "Fizz", 7, 8, "Fizz", "Buzz", 11, "Fizz", 13, 14, "FizzBuzz", 16, 17, "Fizz", 19, "Buzz"]
```
1. Sum list 
```
MyList.sum([1,2,3,4,5])
# => 15
```
1. my_reduce
```
MyList.my_reduce([1,2,3,4,5], 3, fn (el, acc) -> acc = acc * el end)
# => 360
```
1. my_select
```
MyList.my_select([1,2,3,4], fn el -> rem(el, 2) == 0 end)
# => [2, 4]
```
1. my_any?
```
MyList.my_any?([1,2,3,4,5], fn el -> rem(el, 3) == 0 end)
# => true
MyList.my_any?([1,2,3,4,5], fn el -> rem(el, 7) == 0 end)
# => false
```
1. my_map
```
MyList.my_map([1,2,3,4], fn el -> el * el end)
# => [1, 4, 9, 16]
```
1. my_rotate
1. Remove duplicates from list
1. Substrings
1. my_flatten
1. my_zip
1. Binary Search
1. Mergesort
1. Curry

Remember:

cheatsheet: https://www.dropbox.com/s/lr1t87rw4wfnyb3/elixir-cheat-sheet-v2.pdf?dl=0

open file in iex: `iex fizzbuzz.ex`

method definition shorthand: `def go(num), do: IO.puts(num)`

processes tab in `:observer` will list the name and current function of each
process

[solutions](./intro_elixir_solutions.md)