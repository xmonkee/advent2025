import gary
import gary/array
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/order
import gleam/regexp
import gleam/string
import utils

const input = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
"

type Lights =
  gary.ErlangArray(Bool)

type Button =
  List(Int)

type Joltage =
  gary.ErlangArray(Int)

type Machine {
  Machine(lights: Lights, buttons: List(Button), joltage: Joltage)
}

pub fn main() {
  let input = utils.get_input(10)
  let machines =
    input |> string.drop_end(1) |> string.split("\n") |> list.map(parse_row)
  echo int.sum(list.map(machines, get_min_flips))
}

fn get_min_flips(machine: Machine) {
  echo machine
  let assert Ok(initial_joltage) =
    machine.joltage
    |> array.get_size()
    |> array.create_fixed_size(0)

  let assert Ok(flips) = get_min_flips_dfs(initial_joltage, machine, 0)
  flips
}

fn get_min_flips_dfs(joltage: Joltage, machine: Machine, flips: Int) {
  echo #(flips)
  case
    compare_joltage(joltage, machine.joltage, array.get_size(joltage), order.Eq)
  {
    order.Eq -> Ok(flips)
    order.Gt -> Error(Nil)
    order.Lt -> {
      try_buttons(joltage, machine.buttons, machine, flips)
    }
  }
}

fn try_buttons(
  joltage: Joltage,
  buttons: List(Button),
  machine: Machine,
  flips: Int,
) {
  case buttons {
    [btn, ..rest] ->
      case get_min_flips_dfs(update_joltage(joltage, btn), machine, flips + 1) {
        Ok(flips) -> Ok(flips)
        Error(Nil) -> try_buttons(joltage, rest, machine, flips)
      }
    [] -> Error(Nil)
  }
}

fn compare_joltage(
  joltage: Joltage,
  target_joltage: Joltage,
  n: Int,
  acc: order.Order,
) {
  case n {
    n if n > 0 -> {
      let assert Ok(a) = array.get(joltage, n - 1)
      let assert Ok(b) = array.get(target_joltage, n - 1)
      case int.compare(a, b) {
        order.Lt -> compare_joltage(joltage, target_joltage, n - 1, order.Lt)
        order.Eq -> compare_joltage(joltage, target_joltage, n - 1, acc)
        order.Gt -> order.Gt
      }
    }
    _ -> acc
  }
}

fn update_joltage(joltage: Joltage, button: Button) {
  case button {
    [] -> joltage
    [pos, ..rest_switches] -> {
      let assert Ok(cnt) = array.get(joltage, pos)
      let assert Ok(new_joltage) = array.set(joltage, pos, cnt + 1)
      update_joltage(new_joltage, rest_switches)
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
