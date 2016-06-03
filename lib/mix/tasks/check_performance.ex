defmodule Mix.Tasks.Performance do
  Code.load_file("configured_anagrams.ex", "test")
  use Mix.Task

  def timey_time_time_time do
    {_, secs, micros} = :os.timestamp
    secs*1000000 + micros
  end

  def run(_args) do
    dict = Anagrams.Dictionary.load_human_readable_dictionary("/Users/nathanl/code/wordular/tmp/sil_wordlist.txt")
    IO.puts "loaded the dictionary file - size #{Enum.count(dict)}"
    start = timey_time_time_time
    results = ConfiguredAnagrams.of("racecars are rad me lad", dict)
    the_end = timey_time_time_time
    IO.puts "anagram generation took #{the_end - start}"
    IO.puts "result count: #{Enum.count(results)}"
    IO.inspect results
    File.write!("tmp/results.txt", results) # TODO make it put one anagram per line
  end
end
