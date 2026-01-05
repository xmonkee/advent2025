import gary
import gary/array
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/order
import gleam/regexp
import gleam/result
import gleam/string
import utils

const input = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {30,50,40,70}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
"

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
  // let input = utils.get_input(10)
  let machines =
    input |> string.drop_end(1) |> string.split("\n") |> list.map(parse_row)

  echo list.map(machines, get_min_flips)
}

fn get_min_flips(machine: Machine) {
  get_min_flips_(
    machine,
    list.index_map(machine.buttons, fn(btn, idx) { #(idx, btn) }),
    [],
  )
}

fn get_min_flips_(machine: Machine, buttons, pressed) {
  case joltage_order(machine) {
    order.Lt -> Error(Nil)
    order.Eq -> Ok(0)
    order.Gt -> {
      case buttons {
        [] -> Error(Nil)
        [idx_btn, ..rst] -> {
          let #(idx, btn) = idx_btn
          case
            get_min_flips_(
              update_joltage(machine, btn),
              buttons,
              list.append(pressed, [idx]),
            )
          {
            Ok(n) -> Ok(n + 1)
            Error(Nil) -> get_min_flips_(machine, rst, pressed)
          }
        }
      }
    }
  }
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
