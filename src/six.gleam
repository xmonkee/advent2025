import gleam/int
import gleam/list
import gleam/regexp
import gleam/string
import utils

// const input = "123 328  51 64
//  45 64  387 23
//   6 98  215 314
// *   +   *   +
// "

pub fn main() {
  let input = utils.get_input(6)
  let lines =
    string.split(input |> string.drop_end(1), "\n") |> list.map(string.trim)
  let pattern = utils.unwrap(regexp.from_string(" +"))
  let rows = list.map(lines, fn(line) { regexp.split(pattern, line) })
  let cols = rows |> list.transpose() |> list.map(list.reverse)
  echo cols |> list.map(calc_col) |> int.sum()
}

fn calc_col(list: List(String)) -> Int {
  case list {
    [] -> panic as "impossible"
    [op, ..nums] -> {
      let nums = list.map(nums, utils.parse_int)
      let #(zero, fun) = bin_fun(op)
      list.fold(nums, zero, fun)
    }
  }
}

fn bin_fun(op: String) -> #(Int, fn(Int, Int) -> Int) {
  case op {
    "+" -> #(0, fn(x, y) { x + y })
    "*" -> #(1, fn(x, y) { x * y })
    _ -> panic as "impossiburu"
  }
}
