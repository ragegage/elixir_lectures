# Game of Life

## 1. Create new app

Plan out the app. My plan, if you'd like to follow along, is as follows:

> We'll build out a simple game of life simulator, which will have a board that
is in charge of creating, managing, and rendering cells. The board will have a
size (both `x` and `y`), a List of `cell_pids`, a Map `snapshot` of the current
landscape, an integer `count` of how many responses it has received, and the
`pid` of the main GameOfLife process. Each cell will have a `position` tuple
and a boolean `alive?` property.

> We'll start by creating the Cell module as a simple loop that receives `:turn`
messages from the board, at which point it counts how many of its neighbors are
alive, and assesses what its own `alive?` property should be. Once that is
computed, the cell should send back a `:cell` message with its `alive?`
property.

> The board, similarly, will start out as a simple loop that receives `:turn`
messages from the main GameOfLife process. For each `:turn`, the board should
reset its `count` and `snapshot` properties and send a `:turn` message to each
cell with the current state of the board. Once the cell is done computing, it
will send the board a `:cell` message. When the board receives a `:cell`
message, it should add that message's data to the current `snapshot` it is
building and increment its `count`. Once the `count` is `size * size` (i.e.,
once it has received a message from all of the cells), the board should render
its snapshot, joining each row of cells together and printing them to the
console. The board should also send a message to the main GameOfLife process at
this point.

> Finally, we'll create a GameOfLife process that allows the user to start a new
simulation with a given size and then loops continuously, sending the board a
`:turn` message 100ms after it last received a response from the board.

As before, start by running `mix new game_of_life`, which will create a new app
called `game_of_life`.
