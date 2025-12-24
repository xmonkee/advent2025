import gleam/string
import gleam/list
import gleam/int
import utils

pub fn main() {
	let lines = utils.get_lines(3)
	echo lines |> list.map(joltage) |> int.sum
	Nil
}

//fn joltage(s: String) {
	//let sl = string.split(s, "") |> list.map(utils.parse_int) 
	//use #(max, max_idx) <- option.map(find_max(sl))
	//let lm = find_max(list.take(sl, max_idx))
	//let rm = find_max(list.drop(sl, max_idx + 1))
	//case lm, rm {
		//_, Some(#(rmax, _)) -> max * 10 + rmax
		//Some(#(lmax, _)), None -> lmax * 10 + max
		//None, None -> panic as "Won't happen"
	//}
//}

//fn find_max(sl: List(Int)) {
	//case sl {
		//[] -> None
		//_ -> {
			//Some(list.index_fold(sl, #(0, 0), fn(acc, item, idx) {
				//let #(max, max_idx) = acc
				//case item > max {
					//True -> #(item, idx)
					//False -> #(max, max_idx)
				//}
			//}))
		//}
	//}
//}

fn joltage(s: String) {
	let nums = find_maxes(s)
	let #(prod, _) = list.fold(nums, #(0, 0), fn(acc, n) {
		let #(prod, pow) = acc
		#(prod + ten_power(n, pow), pow + 1)	
	})
	prod
}

fn ten_power(acc: Int, pow: Int) {
	case pow {
		0 -> acc
	  _ -> ten_power(acc * 10, pow - 1)
	}
}

fn find_maxes(s: String) -> List(Int) {
	let #(maxes, _) = list.fold(list.range(11, 0), #([], -1), fn(acc, remaining) {
		let #(maxes, prev_idx) = acc
		let #(max, max_idx) = next_max(s, prev_idx+1, remaining) 
		#([max, ..maxes], max_idx)
	})
	maxes
}

fn next_max(s: String, start_idx: Int, remaining: Int) {
	let rem_string = s |> string.drop_start(start_idx) |> string.drop_end(remaining)
	let rem_list = rem_string |> string.split("") |> list.map(utils.parse_int)
	let #(max, max_idx) = find_max(rem_list, #(0, 0), 0)
	#(max, start_idx + max_idx)
}

fn find_max(s: List(Int), acc: #(Int, Int), idx: Int) {
	let #(max, max_idx) = acc
	case s {
		[] -> #(max, max_idx)
		[n, ..rest] if n > max -> find_max(rest, #(n, idx), idx + 1)
		[_, ..rest] -> find_max(rest, #(max, max_idx), idx + 1)
	}
}


