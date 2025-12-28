import gleam/list
import gleam/string
import utils

// const input = ".......S.......
// ...............
// .......^.......
// ...............
// ......^.^......
// ...............
// .....^.^.^.....
// ...............
// ....^.^...^....
// ...............
// ...^.^...^.^...
// ...............
// ..^...^.....^..
// ...............
// .^.^.^.^.^...^.
// ..............."

pub fn main() {
  let input = utils.get_input(7) |> string.drop_end(1)
  let lines = input |> string.split("\n") |> list.map(string.split(_, ""))
  echo solve(lines)
}

fn solve(lines) {
  let state = lines |> list.first() |> utils.unwrap() |> list.map(fn(_) { 1 })
  let lines = list.reverse(lines)
  fire(lines, state)
}

fn fire(lines, state) {
  case lines {
    [line] -> get_s(line, state)
    [line, ..rest] -> {
      let nstate = update(state, line)
      fire(rest, nstate)
    }
    [] -> panic as "should've returned value at S"
  }
}

fn update(state, line) {
  // Dynamic programming. Count from last line. Each splitter's value is sum of the last two values on either side of it
  case state, line {
    [], [] -> []
    [a, _, c, ..rstate], [".", "^", ".", ..rline] -> {
      [a, a + c, ..update([c, ..rstate], [".", ..rline])]
    }
    [a, ..rstate], [".", ..rline] -> [a, ..update(rstate, rline)]
    _, _ -> panic as "wtf"
  }
}

fn get_s(line, state) {
  case line, state {
    ["S", ..], [n, ..] -> n
    [_, ..rline], [_, ..rstate] -> get_s(rline, rstate)
    _, _ -> panic as "impossible"
  }
}
