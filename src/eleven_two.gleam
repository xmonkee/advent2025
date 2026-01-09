import gleam/dict
import gleam/list
import gleam/string
import rememo/memo
import utils

pub fn main() {
  let input = utils.get_input(11)
  let pairs = input |> string.drop_end(1) |> string.split("\n")
  let graph = pairs |> list.map(parse_row) |> dict.from_list
  use cache <- memo.create()

  echo traverse(graph, "svr", cache).both
}

pub type Cnt {
  Cnt(fft: Int, dac: Int, both: Int, none: Int)
}

fn traverse(graph, inp, cache) {
  use <- memo.memoize(cache, inp)
  case inp {
    "out" -> Cnt(0, 0, 0, 1)
    _ ->
      case dict.get(graph, inp) {
        Error(_) -> Cnt(0, 0, 0, 0)
        Ok(lst) ->
          lst |> list.map(traverse(graph, _, cache)) |> process_paths(inp)
      }
  }
}

fn process_paths(paths: List(Cnt), inp: String) -> Cnt {
  list.fold(paths, Cnt(0, 0, 0, 0), fn(acc, path) {
    let pp = process_path(path, inp)
    Cnt(
      both: acc.both + pp.both,
      fft: acc.fft + pp.fft,
      dac: acc.dac + pp.dac,
      none: acc.none + pp.none,
    )
  })
}

fn process_path(path: Cnt, inp: String) {
  case inp {
    "fft" ->
      Cnt(
        both: path.both + path.dac,
        fft: path.fft + path.none,
        dac: 0,
        none: 0,
      )
    "dac" ->
      Cnt(
        both: path.both + path.fft,
        dac: path.dac + path.none,
        fft: 0,
        none: 0,
      )
    _ -> path
  }
}

fn parse_row(row: String) -> #(String, List(String)) {
  let assert [inp, outs] = string.split(row, ": ")
  #(inp, string.split(outs, " "))
}
