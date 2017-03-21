# Introductory Elixir Problems

First, make sure you have elixir [installed](http://elixir-lang.org/install.html).

## Remember:

+ Take a look at some [example elixir code snippets](./demos/intro_elixir_code_demo.md) or this great [cheatsheet](https://www.dropbox.com/s/lr1t87rw4wfnyb3/elixir-cheat-sheet-v2.pdf?dl=0) if you get stuck with the syntax
+ Try things out in `iex`
+ Open files in iex using `iex fizzbuzz.ex`

1. MyRange
```
MyRange.create(4, 9)
# => [4, 5, 6, 7, 8, 9]
```

2. FizzBuzz
```
FizzBuzz.fizz_buzz((1..20))
# => [1, 2, "Fizz", 4, "Buzz", "Fizz", 7, 8, "Fizz", "Buzz", 11, "Fizz", 13, 14, "FizzBuzz", 16, 17, "Fizz", 19, "Buzz"]
```

3. Sum list
```
MyList.sum([1,2,3,4,5])
# => 15
```

4. my_reduce
```
MyList.my_reduce([1,2,3,4,5], 3, fn (el, acc) -> acc = acc * el end)
# => 360
```

5. my_select
```
MyList.my_select([1,2,3,4], fn el -> rem(el, 2) == 0 end)
# => [2, 4]
```

6. my_any?
```
MyList.my_any?([1,2,3,4,5], fn el -> rem(el, 3) == 0 end)
# => true
MyList.my_any?([1,2,3,4,5], fn el -> rem(el, 7) == 0 end)
# => false
```

7. my_map
```
MyList.my_map([1,2,3,4], fn el -> el * el end)
# => [1, 4, 9, 16]
```

8. my_rotate
```
MyList.my_rotate([1,2,3,4], -3)
# => [2, 3, 4, 1]
MyList.my_rotate([1,2,3,4], 3)
# => [4, 1, 2, 3]
```

9. Remove duplicates from list
```
MyList.my_uniq([1,2,3,4,3,2,1,2,3,4,3,2,1])
# => [1, 2, 3, 4]
```

10. Substrings
```
Substrings.substrings "abcd"
# => ["d", "cd", "c", "bcd", "bc", "b", "abcd", "abc", "ab", "a", ""]
```
11. my_flatten
```
MyList.my_flatten([1,[1,[1,2,3],2,3],2,3], [])
# => [1, 1, 1, 2, 3, 2, 3, 2, 3]
```

12. my_zip
```
MyList.my_zip([1,2,3],[4,5,6])
# => [[1, 4], [2, 5], [3, 6]]
```

13. Mergesort
```
Mergesort.sort [1,4,23,6,2,5,6,3]
# => [1, 2, 3, 4, 5, 6, 6, 23]
```

14. Curry
```
fun = fn (a,b,c) -> a + b + c end
f1 = Curry.curry fun
f2 = f1.(1)
f3 = f2.(2)
f3.(3)
# => 6
fun2 = fn (a,b,c) -> a * b * c end
f1 = Curry.curry fun2
f1.(1).(2).(3)
# => 6
```

[solutions](./intro_elixir_solutions.ex)
