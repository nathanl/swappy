defmodule Mix.Tasks.Performance do
  Code.load_file("basic_anagram_user.ex", "test")
  use Mix.Task

  def timey_time_time_time do
    {_, secs, micros} = :os.timestamp
    secs*1000000 + micros
  end

  defmodule PerfModule do
    @wordlists %{default: Anagram.Dictionary.load_file("~/code/anagram_wordlists/pruned_wordlist_by_length.txt")}
    # @wordlists Map.merge(Anagram.default_wordlists, @custom_wordlists)

    use Anagram, wordlists: @wordlists
  end



  # NOTE: http://wordsmith.org/anagram/anagram.cgi?anagram=racecars+are+rad+me+lad&language=english&t=100&d=&include=&exclude=&n=&m=&source=adv&a=n&l=n&q=n&k=1 finds 78,948 anagrams for "racecars are rad me lad". We find 2,370,369 in a similar amount of time. :) I think the main factor is the dictionary.
  def run(_args) do
    # dict = Anagram.Dictionary.load_file("~/code/anagram_wordlists/pruned_wordlist_by_length.txt")
    # dict = Anagram.Dictionary.load_file("~/code/anagram/lib/common_words_dictionary.txt")

    # IO.puts "loaded the dictionary file - size #{Enum.count(dict)}"
    IO.puts "STARTING"
    start = timey_time_time_time
    # results = BasicAnagramUser.anagrams_of("racecars are rad me lad", dict)
    results = PerfModule.anagrams_of("racecars are rad me lad")
    the_end = timey_time_time_time
    IO.puts "anagram generation took #{the_end - start}"
    IO.puts "result count: #{Enum.count(results)}"
    IO.inspect results
    output = results |> Enum.map(fn (result) -> [result, "\n"] end)
    File.write!("tmp/results.txt", output)
  end
end
