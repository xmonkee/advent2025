import dotenv_gleam
import envoy
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/string



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

	assert resp.status == 200
	resp.body
}

pub fn get_lines(n: Int) {
	let input = get_input(n)
	input |> string.drop_end(1) |> string.split("\n")
}


