import gleam/dict
import gleam/int
import gleam/list
import gleam/string
import utils

// const input = "162,817,812
// 57,618,57
// 906,360,560
// 592,479,940
// 352,342,300
// 466,668,158
// 542,29,236
// 431,825,988
// 739,650,466
// 52,470,668
// 216,146,977
// 819,987,18
// 117,168,530
// 805,96,715
// 346,949,466
// 970,615,88
// 941,993,340
// 862,61,35
// 984,92,344
// 425,690,689
// "

type Point =
  #(Int, Int, Int)

type Pair =
  #(Point, Point)

type DPair =
  #(Int, Pair)

type Domains =
  dict.Dict(Point, Point)

pub fn main() {
  let input = utils.get_input(8)
  let lines = input |> string.drop_end(1) |> string.split("\n")
  let points = list.map(lines, parse_points)
  let pairs = list.combination_pairs(points)
  let dpairs = list.map(pairs, fn(pair) { #(distance(pair), pair) })
  let sorted = dpairs |> list.sort(compare_dpairs)
  let uf = points |> list.map(fn(p) { #(p, p) }) |> dict.from_list()
  let ldomains = list.length(points)
  let last_pair = #(#(0, 0, 0), #(0, 0, 0))
  let last_pair = join_while_disconnected(sorted, uf, ldomains, last_pair)
  let #(#(x1, _, _), #(x2, _, _)) = last_pair
  echo x1 * x2
}

fn parse_points(line) {
  let points = line |> string.split(",") |> list.map(utils.parse_int)
  case points {
    [x, y, z] -> #(x, y, z)
    _ -> panic as "Bad input"
  }
}

fn distance(pair: Pair) -> Int {
  let #(p1, p2) = pair
  let #(x1, y1, z1) = p1
  let #(x2, y2, z2) = p2

  { x1 - x2 }
  * { x1 - x2 }
  + { y1 - y2 }
  * { y1 - y2 }
  + { z1 - z2 }
  * { z1 - z2 }
}

fn compare_dpairs(d1: DPair, d2: DPair) {
  case d1, d2 {
    #(d1, _), #(d2, _) -> int.compare(d1, d2)
  }
}

fn join_while_disconnected(
  dpairs: List(DPair),
  uf: Domains,
  ldomains: Int,
  last_pair: #(Point, Point),
) {
  case ldomains, dpairs {
    1, _ -> last_pair
    _, [] -> panic as "Ran out of pairs"
    _, [#(_, #(p1, p2)), ..rest] -> {
      let #(new_uf, was_joined) = union(uf, p1, p2)
      let ldomains = case was_joined {
        True -> ldomains - 1
        False -> ldomains
      }
      join_while_disconnected(rest, new_uf, ldomains, #(p1, p2))
    }
  }
}

// Ah, union-find, my old friend

fn union(acc: Domains, p1: Point, p2: Point) {
  let #(root1, dist1) = find(acc, p1)
  let #(root2, dist2) = find(acc, p2)
  case root1, root2, dist1, dist2 {
    r1, r2, _, _ if r1 == r2 -> #(acc, False)
    r1, r2, d1, d2 if d1 > d2 -> #(dict.insert(acc, r2, r1), True)
    r1, r2, _, _ -> #(dict.insert(acc, r1, r2), True)
  }
}

fn find(acc: Domains, to_find: Point) -> #(Point, Int) {
  let parent = dict.get(acc, to_find)
  case parent {
    Ok(parent) if parent == to_find -> #(parent, 0)
    Ok(parent) -> {
      let #(root, dist) = find(acc, parent)
      #(root, dist + 1)
    }
    _ -> panic as "Everything should already have a parent"
  }
}
