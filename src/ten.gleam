import gary
import gary/array
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/string
import utils

// const input = "[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
// [...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
// [.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
// "

type Lights =
  gary.ErlangArray(Bool)

type Button =
  List(Int)

type Joltage =
  List(Int)

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
  let initial_lights =
    machine.lights
    |> array.get_size()
    |> list.repeat(False, _)
    |> array.from_list(False)

  get_min_flips_dfs([#(initial_lights, 0)], machine)
}

fn get_min_flips_dfs(q, machine: Machine) {
  case q {
    [#(lights, depth), ..rest] -> {
      case lights == machine.lights {
        True -> depth
        False -> {
          // new lights (and depth)
          let new_lds =
            machine.buttons
            |> list.map(update_lights(lights, _))
            // filter out already visited lights
            |> list.filter(fn(new_light) {
              !list.any(q, fn(ld_visited) {
                let #(lvisited, _) = ld_visited
                lvisited == new_light
              })
            })
            |> list.map(fn(l) { #(l, depth + 1) })

          let new_q = list.append(rest, new_lds)
          get_min_flips_dfs(new_q, machine)
        }
      }
    }
    [] -> panic as "Not possible"
  }
}

fn update_lights(lights: Lights, button: Button) {
  case button {
    [] -> lights
    [pos, ..rest_switches] -> {
      let assert Ok(on_or_off) = array.get(lights, pos)
      let assert Ok(new_lights) = array.set(lights, pos, !on_or_off)
      update_lights(new_lights, rest_switches)
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
  let joltage = joltage |> string.split(",") |> list.map(utils.parse_int)
  Machine(lights, buttons, joltage)
}
