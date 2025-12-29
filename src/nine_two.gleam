import gleam/bool
import gleam/int
import gleam/list
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
  let points =
    input |> string.drop_end(1) |> string.split("\n") |> list.map(parse_point)

  // 1 is connected to 2, 2 is connected to 3... n is connected back to 1
  let assert Ok(last) = list.last(points)
  let segments = list.window_by_2([last, ..points])

  // Rectangles are formed between pairs of points
  let pairs = list.combination_pairs(points)
  let valid_pairs = list.filter(pairs, is_valid(_, segments))

  let assert Ok(max_rect) =
    list.max(valid_pairs, fn(r1, r2) { int.compare(area(r1), area(r2)) })

  // echo max_rect
  echo area(max_rect)
}

fn area(r1: #(Point, Point)) -> Int {
  let #(#(x1, y1), #(x2, y2)) = ordered_points(r1)
  { x2 - x1 + 1 } * { y2 - y1 + 1 }
}

fn parse_point(s) {
  let assert [x, y] = s |> string.split(",") |> list.map(utils.parse_int)
  #(x, y)
}

fn is_valid(rect: #(Point, Point), segments: List(#(Point, Point))) -> Bool {
  // all segments must be outside (or on) this rectangle for this pair to be valid
  let is_clean = list.any(segments, is_inside(rect, _)) |> bool.negate
  // the rectangle must be internal to the shape
  let is_internal = is_internal(rect, segments)
  is_clean && is_internal
}

fn is_inside(rect: #(Point, Point), segment: #(Point, Point)) -> Bool {
  let #(#(xmin, ymin), #(xmax, ymax)) = ordered_points(rect)
  let #(#(x1, y1), #(x2, y2)) = ordered_points(segment)
  assert x1 == x2 || y1 == y2
  case x1 == x2 {
    // Vertical
    True -> { x1 > xmin && x1 < xmax } && !{ y2 <= ymin || y1 >= ymax }
    // Horizontal
    False -> { y1 > ymin && y1 < ymax } && !{ x2 <= xmin || x1 >= xmax }
  }
}

fn is_internal(rect: #(Point, Point), segments: List(#(Point, Point))) -> Bool {
  // is point inside shape
  let #(#(x1, y1), #(x2, y2)) = rect
  let #(x, y) = #({ x1 + x2 } / 2, { y1 + y2 } / 2)
  // Draw a fictional line from (0, y) to (x, y) and see how many segments it intersects
  let intersections =
    list.count(segments, fn(segment) {
      // Does fictional line interect segment
      let #(#(x1, y1), #(x2, y2)) = ordered_points(segment)
      case x1 == x2 {
        // vertical
        True -> { x1 <= x } && { y1 <= y && y2 >= y }
        // horizontal
        False -> { x1 <= x } && { y1 == y }
      }
    })
  // if it's an odd number, it must be inside the shape
  intersections % 2 == 1
}

fn ordered_points(pair: #(Point, Point)) {
  let #(#(x1, y1), #(x2, y2)) = pair
  let #(x1, x2) = ordered_pair(x1, x2)
  let #(y1, y2) = ordered_pair(y1, y2)
  #(#(x1, y1), #(x2, y2))
}

fn ordered_pair(a: Int, b: Int) {
  case a < b {
    True -> #(a, b)
    False -> #(b, a)
  }
}
