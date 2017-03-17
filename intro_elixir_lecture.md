
# Intro to Elixir

Agenda:

+ what is elixir
+ simple demo
+ processes demo

Note:
[main source](http://elixir-lang.org/getting-started/introduction.html)

---

## elixir & erlang:

### known for
+ concurrency
+ fault tolerance
+ distribution
+ high availability
<br/><br/>
### features
+ immutable
+ functional
+ process-based

Note:
Erlang was WhatsApp's "secret sauce" - https://blog.whatsapp.com/170/ONE-MILLION%21?p=170

helped bleacherreport scale ridiculously - https://cdn.ampproject.org/c/www.techworld.com/apps/how-elixir-helped-bleacher-report-handle-8x-more-traffic-3653957/?amp

Erlang ("Ericsson language") is a component of Ericsson, which has about a 35 percent global market share in the wireless network infrastructure.

Elixir was created by José Valim, a Rails core team member, in 2011.

2mil simultaneous users: http://www.phoenixframework.org/blog/the-road-to-2-million-websocket-connections

[intro to erlang](http://learnyousomeerlang.com/introduction)

[pros and cons of erlang](http://learnyousomeerlang.com/introduction#kool-aid)

[concurrency](http://learnyousomeerlang.com/the-hitchhikers-guide-to-concurrency)

http://highscalability.com/blog/2014/2/26/the-whatsapp-architecture-facebook-bought-for-19-billion.html

http://blog.carbonfive.com/2016/04/19/elixir-and-phoenix-the-future-of-web-apis-and-apps/

Hex is the package manager for elixir

---

## Simple Demos

Note:

lists are stored in memory as linked lists; prepending elements is O(1) but finding the length is O(n).

because data types are immutable in elixir, the original tuple isn't changed.

tuples are stored contiguously in memory; finding the length is O(1) but changing elements is O(n) because it requires copying the tuple's entire contents to a new tuple.

(you can use the `^` operator to pattern match against a variable's value:)

if you don't care about a value in a pattern, you can use `_` to fill that space.

you can compile modules using the `elixirc` command in the terminal (e.g., `elixirc math.ex`)

you can also compile and run `.exs` files without creating a `.beam` file like so: `elixir math.exs`

inside modules, `def` creates public functions while `defp` creates private functions

functions can have guards

no `for` loops in elixir - only recursion!

but in general, use the `Enum` module, which has most of the normal functions in it (`reduce`, `map`, &c.)

`Enumerable` is similar to ruby's: the functions work with any data type that implements its protocol.

you can pipe the results of a function directly into another function using `|>`

---

ty