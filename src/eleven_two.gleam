import gleam/dict
import gleam/list
import gleam/result
import gleam/string
import rememo/memo
import utils

pub type Cnt {
  Cnt(fft: Int, dac: Int, both: Int, none: Int)
}

pub fn main() {
  let graph =
    utils.get_input(11)
    |> string.drop_end(1)
    |> string.split("\n")
    |> list.map(parse_row)
    |> dict.from_list

  use cache <- memo.create()
  echo traverse("svr", graph, cache).both
}

fn traverse(inp, graph, cache) -> Cnt {
  use <- memo.memoize(cache, inp)

  case inp {
    "out" -> Cnt(0, 0, 0, 1)
    _ ->
      dict.get(graph, inp)
      |> result.unwrap([])
      |> list.fold(Cnt(0, 0, 0, 0), fn(acc, out) {
        out |> traverse(graph, cache) |> adjust(inp) |> add(acc)
      })
  }
}

fn add(a: Cnt, b: Cnt) -> Cnt {
  Cnt(
    fft: a.fft + b.fft,
    dac: a.dac + b.dac,
    both: a.both + b.both,
    none: a.none + b.none,
  )
}

fn adjust(c: Cnt, inp: String) -> Cnt {
  // This is the real heart of the logic.
  // If I am at fft, how do the 4 values we are tracking change, if they are coming from a child path
  case inp {
    "fft" -> Cnt(both: c.both + c.dac, fft: c.fft + c.none, dac: 0, none: 0)
    "dac" -> Cnt(both: c.both + c.fft, dac: c.dac + c.none, fft: 0, none: 0)
    _ -> c
  }
}

fn parse_row(row: String) -> #(String, List(String)) {
  let assert [inp, outs] = string.split(row, ": ")
  #(inp, string.split(outs, " "))
}
