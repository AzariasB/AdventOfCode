import argv
import clip.{type Command}
import clip/help
import clip/opt.{type Opt}
import envoy
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/io
import gleam/string
import gleam/time/calendar
import gleam/time/timestamp
import simplifile
import util/file

type DownloadArgs {
  DownloadArgs(year: Int, day: Int)
}

fn current_date() -> calendar.Date {
  let now = timestamp.system_time()
  let #(date, _time) = timestamp.to_calendar(now, calendar.utc_offset)
  date
}

fn year_opt() -> Opt(Int) {
  opt.new("year")
  |> opt.int
  |> opt.help("Year to download the exercise from")
  |> opt.default(2025)
  //current_date().year)
}

fn day_opt() -> Opt(Int) {
  opt.new("day")
  |> opt.int
  |> opt.help("Day to download the exercise")
  |> opt.default(current_date().day)
}

fn command() -> Command(DownloadArgs) {
  clip.command({
    use year <- clip.parameter
    use day <- clip.parameter

    DownloadArgs(year, day)
  })
  |> clip.opt(year_opt())
  |> clip.opt(day_opt())
}

fn prepare_exercise(args: DownloadArgs) {
  io.println(
    "Downloading exercise for "
    <> int.to_string(args.year)
    <> " - day "
    <> int.to_string(args.day),
  )

  let assert Ok(_wrote) =
    download_input(args)
    |> simplifile.write(
      to: "./input/day"
      <> string.pad_start(int.to_string(args.day), to: 2, with: "0")
      <> ".txt",
    )
    as "Failed to create input file"

  args |> prepare_code |> prepare_test
  Nil
}

fn prepare_test(args: DownloadArgs) -> DownloadArgs {
  let day_format =
    "day" <> string.pad_start(int.to_string(args.day), to: 2, with: "0")

  let content = file.read("./test/aoc_2026_test.gleam")

  case string.contains(content, "import " <> day_format) {
    True -> {
      Nil
    }
    False -> {
      let nw_content =
        "import "
        <> day_format
        <> "\n"
        <> content
        <> "\n\npub fn "
        <> day_format
        <> "_test() {\n assert "
        <> day_format
        <> ".part_1(\"./input/"
        <> day_format
        <> ".txt\") == 0\n assert "
        <> day_format
        <> ".part_2(\"./input/"
        <> day_format
        <> ".txt\") == 0\n}"
      let assert Ok(res) =
        simplifile.write("./test/aoc_2026_test.gleam", nw_content)
      res
    }
  }
  args
}

fn prepare_code(args: DownloadArgs) -> DownloadArgs {
  let day_format =
    "day" <> string.pad_start(int.to_string(args.day), to: 2, with: "0")
  let target_path = "./src/" <> day_format <> ".gleam"

  let content = file.read("./template.gleam")
  let assert Ok(_) =
    string.replace(content, each: "dayXX", with: day_format)
    |> simplifile.write(to: target_path)
    as { "Failed to write content to " <> target_path }

  args
}

fn download_input(args: DownloadArgs) -> String {
  let url =
    "https://adventofcode.com/"
    <> int.to_string(args.year)
    <> "/day/"
    <> int.to_string(args.day)
    <> "/input"

  let assert Ok(base_req) = request.to(url)

  let assert Ok(session) = envoy.get("ADVENT_OF_CODE_SESSION")

  let assert Ok(resp) =
    request.set_cookie(base_req, "session", session) |> httpc.send

  let err_message =
    "response returned invalid status "
    <> int.to_string(resp.status)
    <> " querying url "
    <> url
  assert resp.status == 200 as err_message

  resp.body
}

pub fn main() -> Nil {
  let result =
    command()
    |> clip.help(help.simple("prepare", "Prepare exercise of the day"))
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error(e)
    Ok(person) -> prepare_exercise(person)
  }
}
