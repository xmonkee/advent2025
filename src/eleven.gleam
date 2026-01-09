import gleam/dict
import gleam/int
import gleam/list
import gleam/string
import rememo/memo
import utils

const input = "aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out
"

pub fn main() {
  let input = utils.get_input(11)
  let pairs = input |> string.drop_end(1) |> string.split("\n")
  let graph = pairs |> list.map(parse_row) |> dict.from_list
  use cache <- memo.create()
  echo traverse(graph, "svr", cache)
}

fn traverse(graph, inp, cache) {
  use <- memo.memoize(cache, inp)
  case dict.get(graph, inp) {
    Error(_) -> 0
    Ok(lst) ->
      case lst {
        ["out"] -> 1
        _ -> lst |> list.map(traverse(graph, _, cache)) |> int.sum
      }
  }
}

fn parse_row(row: String) -> #(String, List(String)) {
  let assert [inp, outs] = string.split(row, ": ")
  #(inp, string.split(outs, " "))
}
