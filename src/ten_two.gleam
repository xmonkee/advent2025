import gary
import gary/array
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/order
import gleam/regexp
import gleam/result
import gleam/string
import rememo/memo
import utils

// const input = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
// [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
// [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
// "

// const input = "[.##.#..##.] (3,6) (0,1,2,3,4,5,7,9) (0,1,5,6,7,8,9) (1,9) (0,1,3,4,5,6,7) (0,1,2,3,4,5) (1,2,3,4,5,6,7,8) (2,3,5,7,8) (2,3,5,7,9) (0,1,2,3,4,6,9) (4,5,6,7,8) (3,6,7,8,9) {52,67,66,109,49,65,70,66,33,72}
// "

// const input = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {30,50,40,70}
// "

type Lights =
  gary.ErlangArray(Bool)

type Button =
  List(Int)

type Joltage =
  gary.ErlangArray(Int)

pub type Machine {
  Machine(lights: Lights, buttons: List(Button), joltage: Joltage)
}

pub fn main() {
  let input = utils.get_input(10)
  let machines =
    input |> string.drop_end(1) |> string.split("\n") |> list.map(parse_row)

  echo int.sum(list.map(machines, get_min_flipss))
}

fn get_min_flipss(machine: Machine) -> Int {
  use cache <- memo.create()
  echo machine
  utils.unwrap(get_min_flips(machine, cache))
}

type FlipsMachinePair {
  FP(flips: Int, machine: Machine)
}

fn get_min_flips(machine: Machine, cache) -> Result(Int, Nil) {
  use <- memo.memoize(cache, machine)
  case joltage_order(machine) {
    order.Eq -> Ok(0)
    order.Lt -> Error(Nil)
    order.Gt -> {
      case is_even(machine) {
        True ->
          machine
          |> half
          |> get_min_flips(cache)
          |> result.map(fn(flips) { flips * 2 })
        False ->
          machine.buttons
          |> subsets
          |> list.map(fn(combo) {
            FP(list.length(combo), list.fold(combo, machine, update_joltage))
          })
          |> list.filter(fn(fm) { is_even(fm.machine) })
          |> list.filter_map(fn(fm) {
            use flips <- result.map(get_min_flips(fm.machine, cache))
            fm.flips + flips
          })
          |> utils.min
      }
    }
  }
}

fn subsets(lst: List(a)) -> List(List(a)) {
  case lst {
    [] -> []
    [fst, ..rst] -> {
      let rst_subs = subsets(rst)
      let appended = rst_subs |> list.map(fn(sub) { [fst, ..sub] })
      [[fst], ..list.append(rst_subs, appended)]
    }
  }
}

fn is_even(machine: Machine) {
  list.all(machine.joltage |> array.to_list, fn(x) { x % 2 == 0 })
}

fn half(machine: Machine) {
  Machine(..machine, joltage: array.map(machine.joltage, fn(_, j) { j / 2 }))
}

fn joltage_order(machine: Machine) {
  let jl = array.to_list(machine.joltage)
  {
    case list.any(jl, fn(x) { x < 0 }) {
      True -> order.Lt
      False -> {
        case list.all(jl, fn(x) { x == 0 }) {
          True -> order.Eq
          False -> order.Gt
        }
      }
    }
  }
}

fn update_joltage(machine: Machine, button: Button) {
  case button {
    [] -> machine
    [pos, ..rest_switches] -> {
      let assert Ok(cnt) = array.get(machine.joltage, pos)
      let assert Ok(joltage) = array.set(machine.joltage, pos, cnt - 1)
      update_joltage(Machine(..machine, joltage: joltage), rest_switches)
    }
  }
}

fn parse_row(s) -> Machine {
  let assert Ok(re) = regexp.from_string("\\[(.*)\\] (.*) {(.*)}")
  let assert [regexp.Match(_, [Some(lights), Some(buttons), Some(joltage)])] =
    regexp.scan(re, s)
  let lights =
    lights
    |> string.split("")
    |> list.map(fn(c) {
      case c {
        "." -> False
        "#" -> True
        _ -> panic as "Bad input"
      }
    })
    |> array.from_list(False)
  let buttons =
    buttons
    |> string.split(" ")
    |> list.map(fn(s) {
      s
      |> string.drop_end(1)
      |> string.drop_start(1)
      |> string.split(",")
      |> list.map(utils.parse_int)
    })
    |> list.sort(fn(btn1, btn2) {
      int.compare(list.length(btn1), list.length(btn2))
    })
    |> list.reverse
  let joltage =
    joltage
    |> string.split(",")
    |> list.map(utils.parse_int)
    |> array.from_list(0)
  Machine(lights, buttons, joltage)
}
