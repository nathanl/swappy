defmodule Mix.Tasks.Performance do
  Code.load_file("configured_anagram.ex", "test")
  use Mix.Task

  def timey_time_time_time do
    {_, secs, micros} = :os.timestamp
    secs*1000000 + micros
  end

  def run(_args) do
    dict = Anagram.Dictionary.load_human_readable_dictionary("~/code/anagram_wordlists/pruned_wordlist_by_length.txt")
    IO.puts "loaded the dictionary file - size #{Enum.count(dict)}"
    start = timey_time_time_time
    results = ConfiguredAnagram.of("racecars are rad me lad", dict)
    the_end = timey_time_time_time
    IO.puts "anagram generation took #{the_end - start}"
    IO.puts "result count: #{Enum.count(results)}"
    IO.inspect results
    File.write!("tmp/results.txt", results) # TODO make it put one anagram per line
  end
end
