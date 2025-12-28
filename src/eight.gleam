import gleam/dict
import gleam/int
import gleam/list
import gleam/pair
import gleam/string
import utils

const input = "162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689
"

type Point =
  #(Int, Int, Int)

type Pair =
  #(Point, Point)

type DPair =
  #(Int, Pair)

type Domains =
  dict.Dict(Point, Point)

type RootCount =
  dict.Dict(Point, Int)

// Union-Find

pub fn main() {
  let input = utils.get_input(8)
  let lines = input |> string.drop_end(1) |> string.split("\n")
  let points = list.map(lines, parse_points)
  let pairs = list.combination_pairs(points)
  let dpairs = list.map(pairs, fn(pair) { #(distance(pair), pair) })
  let sorted = dpairs |> list.sort(compare_dpairs)
  let sorted = sorted |> list.take(1000)
  let uf = points |> list.map(fn(p) { #(p, p) }) |> dict.from_list()
  let joined = join_loop(sorted, uf)
  let domain_sizes = count_members(joined)
  let sorted =
    domain_sizes |> dict.to_list() |> list.sort(compare_dsize) |> list.reverse()
  echo sorted
    |> list.take(3)
    |> list.map(pair.second)
    |> int.product()
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

fn join_loop(dpairs: List(DPair), acc: Domains) {
  case dpairs {
    [] -> acc
    [#(_, #(p1, p2)), ..rest] -> join_loop(rest, union(acc, p1, p2))
  }
}

// Ah, union-find, my old friend

fn union(acc: Domains, p1: Point, p2: Point) {
  let #(root1, dist1) = find(acc, p1)
  let #(root2, dist2) = find(acc, p2)
  case dist1, dist2 {
    d1, d2 if d1 > d2 -> dict.insert(acc, root2, root1)
    _, _ -> dict.insert(acc, root1, root2)
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

fn count_members(doms: Domains) {
  count_members_loop(doms, dict.to_list(doms), dict.new())
}

fn count_members_loop(
  doms: Domains,
  remaining: List(#(Point, Point)),
  acc: RootCount,
) {
  case remaining {
    [d1, ..rest] -> count_members_loop(doms, rest, update_count(acc, d1, doms))
    [] -> acc
  }
}

fn update_count(acc: RootCount, d1: #(Point, Point), doms: Domains) -> RootCount {
  let #(point, parent) = d1
  let #(root, _) = find(doms, parent)
  case dict.get(acc, root) {
    Error(_) -> dict.insert(acc, root, 1)
    Ok(cnt) -> dict.insert(acc, root, cnt + 1)
  }
}

fn compare_dsize(a, b) {
  case a, b {
    #(_, x), #(_, y) -> int.compare(x, y)
  }
}
