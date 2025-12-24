import gleam/result
import gleam/string
import gary
import gary/array
import gleam/list
import gleam/int
import gleam/order
import utils

const input = "..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@."

type A = gary.ErlangArray(gary.ErlangArray(String))

pub fn main() {
	//let input = utils.get_input(4)
	let l = utils.string_to_nested_list(input)
	let r = loop(l)
	echo count_rolls(l) - count_rolls(r)
}

fn count_rolls(l) {
	list.count(list.flatten(l), fn(s) {
		case s {
			"@" -> True
			_ -> False
		}
	})
}

fn get_counts(l: List(List(String))) {
	let a = utils.nested_list_to_array(l)
	let rows = array.get_count(a)
	let cols = a |> array.get(0) |> utils.unwrap() |> array.get_count()
	list.map(list.range(0, rows-1), fn(x) {
		list.map(list.range(0, cols-1), count_neighbors(a, row: x, col: _))	
	})
}

fn loop(l: List(List(String))) {
	let counts = get_counts(l)
	let #(changed, new) = remove(l, counts)
	case changed {
		True -> loop(new)
		False -> new
	}
}

fn remove(l: List(List(String)), counts: List(List(Int))) {
	list.map_fold(list.zip(l, counts), False, fn(changed, r) {
		let #(arow, crow) = r
		list.map_fold(list.zip(arow, crow), changed, fn(ichanged, el) {
			let #(s, c) = el
			case s, c {
				"@", c if c < 4 -> #(True, ".")
				s, _ -> #(ichanged, s)
			}
		})
	})
}


fn count_neighbors(a: A, row row: Int, col col: Int) {
	let nbors = [
		#(row-1, col-1),
		#(row-1, col),
		#(row-1, col+1),
		#(row, col-1),
		#(row, col+1),
		#(row+1, col-1),
		#(row+1, col),
		#(row+1, col+1),
	]	
	let el = get_el(a, row, col)
	case el {
		Ok("@") -> { // Element itself is a roll
			list.count(nbors, fn(nbor) { // Count neighbors
				let #(x, y) = nbor
				let el = get_el(a, x, y)
				case el { 
					Ok(s) -> utils.string_equals(el, "@")
					_			-> False // No neighbor, does not count
				}
			})
		}
		_ -> 1000 // Immovable if not even a roll
	}
}

fn get_el(a: A, x: Int, y: Int) {
	use vx <- result.try(array.get(a, x))
	array.get(vx, y)
}

