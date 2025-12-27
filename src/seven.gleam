import gleam/list
import gleam/string
import utils

const input = ".......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
..............."

pub fn main() {
  let lines =
    input
    |> list.map(string.split(_, ""))
  let state = lines |> list.first() |> utils.unwrap() |> list.map(fn(_) { "." })
  echo fire(lines, state, 0)
}

fn fire(lines, state, cnt) {
  case lines {
    [] -> #(state, cnt)
    [line, ..rest] -> {
      let #(nstate, ncnt) = update(state, line)
      fire(rest, nstate, cnt + ncnt)
    }
  }
}

fn update(state, line) {
  case state, line {
    [_, "|", _, ..srest], [".", "^", ".", ..lrest] ->
      nstep(["|", ".", "|"], srest, lrest, 1)
    [_, "|", ..srest], [".", "^", ..lrest] -> {
      nstep(["|", "."], srest, lrest, 1)
    }
    ["|", _, ..srest], ["^", ".", ..lrest] -> {
      nstep([".", "|"], srest, lrest, 1)
    }
    [_, ..srest], ["S", ..lrest] -> {
      nstep(["|"], srest, lrest, 0)
    }
    [x, ..srest], [".", ..lrest] -> {
      nstep([x], srest, lrest, 0)
    }
    [".", ..srest], [_, ..lrest] -> {
      nstep(["."], srest, lrest, 0)
    }
    [], [] -> #([], 0)
    _, _ -> panic as "WTF"
  }
}

fn nstep(start, srest, lrest, dcnt) {
  let #(nstate, cnt) = update(srest, lrest)
  #(list.append(start, nstate), cnt + dcnt)
}
