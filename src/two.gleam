import gleam/string
import gleam/list
import gleam/result
import gleam/int
import gleam/order
import utils

pub fn main() -> Nil {
	let input = utils.get_input(2)
	let ranges = string.split(input, ",")
	echo int.sum(list.map(ranges, fn(x) {x |> parse_range |> sum_invalid(0)}))
	Nil
}

fn parse_range(range: String) -> #(Int, Int) {
	let parts = string.split(range, "-")
	let #(start, end) = case parts {
		[x, y, ..] -> #(x, y)
		_ -> panic as "bad range"
	}
	let start = result.unwrap(int.parse(start), 0)
	let end = result.unwrap(int.parse(end), 0)
	#(start, end)
}

fn sum_invalid(range: #(Int, Int), acc) -> Int {
	let #(start, end) = range
	case start > end {
		True -> acc
		False -> case is_invalid_two(start) {
			True -> sum_invalid(#(start + 1, end), acc + start)
			False -> sum_invalid(#(start + 1, end), acc)
		}
	}
}

//fn is_invalid(num: Int) {
	//let as_str = int.to_string(num)
	//let s_len = string.length(as_str)
	//case s_len % 2 == 0 {
		//False -> False
		//True -> {
			//let half_len = s_len / 2
			//let first = string.drop_end(as_str, half_len)
			//let second = string.drop_start(as_str, half_len)
			//case string.compare(first, second) {
				//order.Eq -> True
				//_ -> False
			//}
		//}
	//}
//}

fn is_invalid_two(num: Int) {
	let as_str = int.to_string(num)
	let s_len = string.length(as_str)
	case s_len {
		1 -> False
		_ -> {
			let divisors = get_divisors(s_len)
			//echo #(as_str, s_len, divisors)
			list.any(divisors, is_all_same(as_str, _))
		}
	}
}

fn get_divisors(n: Int) {
	case n {
		2 -> [1]
		3 -> [1]
		4 -> [1, 2]
		5 -> [1]
		6 -> [1, 2, 3]
		7 -> [1]
		8 -> [1, 2, 4]
		9 -> [1, 3]
		10 -> [1, 2, 5]
		_ -> panic as "??"
	}
}

fn is_all_same(s: String, l: Int) {
	let first = string.slice(s, 0, l)
	let expected = string.repeat(first, string.length(s) / l)
	case string.compare(expected, s) {
		order.Eq -> True
		_ -> False 
	}
}
