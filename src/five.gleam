import gleam/string
import gleam/list
import gleam/int
import utils

pub fn main_first() {
	let input = utils.get_input(5) |> string.drop_end(1)
	echo case string.split(input, "\n\n") {
		[ranges, ingredients] -> count_fresh(
			parse_ranges(ranges), parse_ing(ingredients))
		_ -> panic as "the disco"
	}
}

pub fn main() {
	let input = utils.get_input(5) |> string.drop_end(1)
	echo case string.split(input, "\n\n") {
		[ranges, _] -> count_fresh_second(parse_ranges(ranges))
		_ -> panic as "the disco"
	}
}

fn parse_ranges(sranges: String) {
	sranges |> string.split("\n") |> list.map(fn(x) {
		case string.split(x, "-") {
			[left, right] -> #(utils.parse_int(left), utils.parse_int(right))
			_ -> panic as "the range"
		}
	})
}

fn parse_ing(singredients: String) {
	singredients |> string.split("\n") |> list.map(utils.parse_int)
}

fn count_fresh(ranges, ingredients) {
	list.count(ingredients, fn(ing) {
		list.any(ranges, fn(range) {
			let #(left, right) = range
			case left, ing, right {
				l, i, r -> l <= i && i <= r
			}
		})
	})
}

fn count_fresh_second(ranges) {
	let sorted = list.sort(ranges, fn(rn1, rn2) {
		let #(l1, _) = rn1
		let #(l2, _) = rn2
		int.compare(l1, l2)
	})
	let merged = merge_ranges(sorted, [])
	list.fold(merged, 0, fn(acc, range) {
		let #(left, right) = range
		acc + right - left + 1
	})
}

fn merge_ranges(ranges, acc) {
	// acc holds range that cannot be merged any further
	case ranges {
		[] -> acc
		[rn] -> [rn, ..acc] // nothing left to merge rn to
		[rn1, rn2, ..rns] -> { 
			let #(l1, r1) = rn1
			let #(l2, r2) = rn2
			case l1, r1, l1, r2 {
				// if rn1 and rn2 are disconnected, move rn1 to acc
				_,_,_,_ if l2 > r1 -> merge_ranges([rn2, ..rns], [rn1, ..acc])
				// rn1 + rn2 become a single longer range
				_,_,_,_ if r2 >= r1 -> merge_ranges([#(l1, r2), ..rns], acc)
				// rn2 is completely subsumed by rn1
				_,_,_,_ if r1 > r2 -> merge_ranges([#(l1, r1), ..rns], acc)
				_,_,_,_ -> panic as "wut"
			}
		}
	}
}

