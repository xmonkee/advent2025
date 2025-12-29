import gleam/int
import gleam/list
import gleam/order
import gleam/string
import utils

// const input = "7,1
// 11,1
// 11,7
// 9,7
// 9,5
// 2,5
// 2,3
// 7,3
// "

type Point =
  #(Int, Int)

pub fn main() {
  let input = utils.get_input(9)
  let lines = input |> string.drop_end(1) |> string.split("\n")
  let points = lines |> list.map(parse_point)
  let pairs = list.combination_pairs(points)
  let assert Ok(max_rect) = list.max(pairs, compare_area)
  echo area(max_rect)
}

fn compare_area(r1: #(Point, Point), r2: #(Point, Point)) -> order.Order {
  int.compare(area(r1), area(r2))
}

fn area(r1: #(Point, Point)) -> Int {
  let #(#(x1, y1), #(x2, y2)) = r1
  int.absolute_value(x1 - x2 + 1) * int.absolute_value(y1 - y2 + 1)
}

fn parse_point(s) {
  let assert [x, y] = s |> string.split(",") |> list.map(utils.parse_int)
  #(x, y)
}
