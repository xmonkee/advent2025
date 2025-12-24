import gleam/list
import gleam/int
import gleam/result
import utils

pub type Acc = #(Int, Int)

pub fn main() -> Nil {
	let lines = utils.get_lines(1)
	echo list.fold(lines, #(50, 0), take_step)
	Nil
}

fn take_step(acc: Acc, step: String) -> Acc {
	let #(pos, cnt) = acc
	case step {
		"L" <> steps -> {
			let parsed = result.unwrap(int.parse(steps), 0)
			let #(new_pos, zeros) = turn_left(pos, parsed)
			#(new_pos, cnt+zeros)
		}
		"R" <> steps -> {
			let parsed = result.unwrap(int.parse(steps), 0)
			let #(new_pos, zeros) = turn_right(pos, parsed)
			#(new_pos, cnt+zeros)
		}
		_ -> panic as "SLDKFJS"
	}
}

fn turn_left(pos: Int, clicks: Int) -> Acc {
	let full_turns = clicks / 100
	let effective_clicks = clicks % 100
	let new_pos = pos - effective_clicks
	case pos, new_pos {
		0, np -> #(np+100, full_turns)
		_, np if np < 0 -> #(np+100, full_turns+1)
		_, np if np == 0 -> #(np, full_turns+1)
		_, np -> #(np, full_turns)
	}
}

fn turn_right(pos: Int, clicks: Int) -> Acc {
	let full_turns = clicks / 100
	let effective_clicks = clicks % 100
	let new_pos = pos + effective_clicks
	case new_pos {
		np if np >= 100 -> #(np - 100, full_turns + 1)
		np -> #(np, full_turns)
	}
}
