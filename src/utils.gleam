import dotenv_gleam
import envoy
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/string
import gary/array
import gleam/list



pub fn parse_int(s: String) {
	let result = int.parse(s)
	case result {
		Ok(x) -> x
		Error(_) -> panic as "not an int"
	}
}

pub fn get_input(n: Int) {
	let assert Ok(Nil) = dotenv_gleam.config()
	let assert Ok(session) = envoy.get("SESSION_COOKIE")
	let assert Ok(req) = request.to(
			"https://adventofcode.com/2025/day/" <> int.to_string(n) <> "/input")
	let assert Ok(resp) =	req 
		|> request.set_cookie("session", session)
		|> httpc.send
	resp.body
}

pub fn get_lines(n: Int) {
	let input = get_input(n)
	input |> string.drop_end(1) |> string.split("\n")
}

pub fn string_to_nested_list(s: String) {
	let lines = string.split(s, "\n")
	list.map(lines, string.split(_, ""))
}

pub fn nested_list_to_array(l: List(List(String))) {
	let al = list.map(l, array.from_list(_, ""))
	array.from_list(al, array.create(""))
}

pub fn unwrap(v: Result(a, b)) -> a {
	case v {
		Ok(a) -> a
		Error(_) -> panic as "Tried to unwrap error"
	}
}
