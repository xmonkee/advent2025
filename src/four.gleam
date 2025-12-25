import gleam/result
import gleam/option.{Some, None}
import gary
import gary/array
import gleam/list
import utils

type A = gary.ErlangArray(gary.ErlangArray(String))

pub fn main() {
	let input = utils.get_input(4)
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

fn loop(l: List(List(String))) {
	let counts = get_counts(l)
	let #(changed, new) = remove(l, counts)
	case changed {
		True -> loop(new)
		False -> new
	}
}

fn get_counts(l: List(List(String))) {
	let a = utils.nested_list_to_array(l)
	let rows = array.get_count(a)
	let cols = a |> array.get(0) |> utils.unwrap() |> array.get_count()
	list.map(list.range(0, rows-1), fn(x) {
		list.map(list.range(0, cols-1), try_count_neighbors(a, row: x, col: _))	
	})
}


fn remove(l, counts) {
	list.map_fold(list.zip(l, counts), False, fn(changed, r) {
		let #(arow, crow) = r
		list.map_fold(list.zip(arow, crow), changed, fn(ichanged, el) {
			let #(s, c) = el
			case s, c {
				"@", Some(c) if c < 4 -> #(True, ".")
				".", Some(_) -> panic as "Shouldn't have counted"
				s, _ -> #(ichanged, s)
			}
		})
	})
}


fn try_count_neighbors(a: A, row row: Int, col col: Int) {
	let el = get_el(a, row, col)
	case el {
		Ok("@") -> Some(count_neighbors(a, row, col))
		_ -> None
	}
}

const nbors = [
	#(-1, -1),
	#(-1,  0),
	#(-1,  1),
	#( 0, -1),
	#( 0,  1),
	#( 1, -1),
	#( 1,  0),
	#( 1,  1),
]	

fn count_neighbors(a: A, x: Int, y: Int) {
	list.count(nbors, fn(nbor) { // Count neighbors
		let #(dx, dy) = nbor
		case get_el(a, x+dx, y+dy) { 
			Ok("@") -> True
			_ -> False
		}
	})
}

fn get_el(a: A, x: Int, y: Int) {
	use vx <- result.try(array.get(a, x))
	array.get(vx, y)
}

