defmodule Mix.Tasks.Performance do
  use Mix.Task

  defmodule PerfModule do
    @wordlists %{default: Swappy.Dictionary.load_file("lib/default_wordlist.txt")}
    use Swappy, wordlists: @wordlists
  end

  def timey_time_time_time do
    {_, secs, micros} = :os.timestamp
    secs*1000000 + micros
  end

  def run(_args) do
    IO.puts "STARTING"
    start = timey_time_time_time
    results = PerfModule.anagrams_of("racecars are rad me lad")
    the_end = timey_time_time_time
    IO.puts "anagram generation took #{the_end - start}"
    IO.puts "result count: #{Enum.count(results)}"
    IO.inspect results
    output = results |> Enum.map(fn (result) -> [result, "\n"] end)
    File.write!("tmp/results.txt", output)
  end
end
