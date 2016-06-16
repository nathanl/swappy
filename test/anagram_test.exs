defmodule AnagramTest do
  Code.load_file("basic_anagram_user.ex", "test")
  Code.load_file("custom_anagram_user.ex", "test")
  use ExUnit.Case
  doctest Anagram

  test "can find the only possible anagrams using a tiny dictionary" do
    result = BasicAnagramUser.anagrams_of("onto", ["on", "to"])
    assert result == ["to on"]
  end

  test "ignores punctuation, capitalization and spaces" do
    result = BasicAnagramUser.anagrams_of("On, To!", ["on", "to"])
    assert result == ["to on"]
  end

  test "can find human-readable anagrams of a phrase using a dictionary" do
    result = BasicAnagramUser.anagrams_of("racecar", ["arc", "are", "car", "care", "race"])
    assert result == ["car race", "car care", "arc race", "arc care"]
  end

  test "can handle duplicate words in the input phrase" do
    result = BasicAnagramUser.anagrams_of("apple racecar apple", ["race", "car", "apple", "racecar"])
    assert result == ["apple racecar apple", "apple race apple car"]
  end

  test "can find words with apostrophes, like 'I'm'" do
    result = BasicAnagramUser.anagrams_of("I'm cool", ["I'm", "cool", "mi"])
    assert result == ["mi cool", "I'm cool"]
  end

  test "uses the built-in default dictionary if none is specified" do
    assert BasicAnagramUser.anagrams_of("onto") == BasicAnagramUser.anagrams_of("onto", :default)
  end

  test "can find anagrams using the built-in default dictionary" do
    result = BasicAnagramUser.anagrams_of("onto")
    assert result == ["to no", "to on", "o ton", "o not", "onto"]
  end

  test "can find anagrams using a dictionary defined in the user's module" do
    result = CustomAnagramUser.anagrams_of("spear", :tiny)
    assert result == ["spear", "spare", "reaps", "pears", "parse", "pares"]
  end

  test "uses legal_codepoints as defined in the user's module" do
    result = CustomAnagramUser.anagrams_of("mañana", :tiny_spanish)
    assert result == ["ña mana", "na maña", "mañana"]
    another_result = CustomAnagramUser.anagrams_of("maana", :tiny_spanish)
    assert another_result != result
    assert another_result == []
  end

  test "human_readable builds a 'cartesian join' of words the alphagrams can spell" do
    anagram = [["a","c","e","r"], ["a","c","r"]]
    dictionary = %{
      ["a", "c", "e", "r"] => ["race", "care"],
      ["a", "c", "r"] => ["car"],
    }
    assert((Anagram.human_readable(anagram, dictionary) |> Enum.sort) == [
      "car care", "car race"
    ])
  end

  def ag(str), do: Anagram.Alphagram.to_alphagram(str)
  def ags(list), do: Enum.map(list, &ag/1)

  test "create_jobs makes jobs for the next level of the search tree" do
    bag = ag("onto")
    possible_words   = ags(["hi", "to", "on", "not"])
    found  = ags([])
    assert Anagram.create_jobs(bag, possible_words, found) == [
      [ found: ags(["to"]), bag: ag("on"),  possible_words: ags(["to"])],
      [ found: ags(["on" ]), bag: ag("to"), possible_words: ags(["on", "to"])],
      [ found: ags(["not" ]), bag: ag("o"), possible_words: ags(["not", "on", "to"])],
    ]
  end

  test "create_jobs adds to the list of found words" do
    bag = ag("onto")
    possible_words   = ags(["hi", "to", "on", "not"])
    found  = ags(["boat"])
    assert Anagram.create_jobs(bag, possible_words, found)  == [
      [ found: ags(["to", "boat"]), bag: ag("on"),  possible_words: ags(["to"])],
      [ found: ags(["on" , "boat"]), bag: ag("to"), possible_words: ags(["on", "to"])],
      [ found: ags(["not" , "boat"]), bag: ag("o"), possible_words: ags(["not", "on", "to"])],
    ]
  end

  # test "it works" do
  #   IO.puts "Make"
  #   dictionary = Anagram.Dictionary.load_file("~/code/anagram_wordlists/pruned_wordlist_by_length.txt") |> Anagram.Dictionary.to_dictionary
  #   wordlist =  Map.keys dictionary
  #   IO.puts "Made"
  #   Anagram.process_queue(
  #     [
  #       [
  #         found: [], bag: ag("racecars are rad me lad"), possible_words: wordlist
  #       ]
  #     ], 1, 0, dictionary
  #   )
  # end

  # test "it can do all this crap in processes" do
  #   bag = ag("onto")
  #   possible_words   = ags(["hi", "to", "on", "not"])
  #   job = [found: [], bag: bag, possible_words: possible_words]
  #   result = Anagram.Queue.process(job)
  #   assert result == ["on to"]
  # end
end
