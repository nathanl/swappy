defmodule AnagramTest do
  Code.load_file("configured_anagram.ex", "test")
  use ExUnit.Case
  doctest Anagram

  test "can find the only possible anagrams using a tiny dictionary" do
    result = ConfiguredAnagram.of("onto", ["on", "to"])
    assert result == ["on to"]
  end

  test "ignores punctuation, capitalization and spaces" do
    result = ConfiguredAnagram.of("On, To!", ["on", "to"])
    assert result == ["on to"]
  end

  test "can find human-readable anagrams of a phrase using a dictionary" do
    result = ConfiguredAnagram.of("racecar", ["arc", "are", "car", "care", "race"])
    assert result == ["race car", "race arc", "care car", "care arc"]
  end

  test "can handle duplicate words in the input phrase" do
    result = ConfiguredAnagram.of("apple racecar apple", ["race", "car", "apple", "racecar"])
    assert result == ["apple racecar apple", "car apple race apple", ]
  end

  test "can find words with apostrophes, like 'I'm'" do
    result = ConfiguredAnagram.of("I'm cool", ["I'm", "cool", "mi"])
    assert result == ["cool mi", "cool I'm"]
  end

  test "human_readable builds a 'cartesian join' of words the alphagrams can spell" do
    anagram = [["a","c","e","r"], ["a","c","r"]]
    dictionary = %{
      ["a", "c", "e", "r"] => ["race", "care"],
      ["a", "c", "r"] => ["car"],
    }
    assert((ConfiguredAnagram.human_readable(anagram, dictionary) |> Enum.sort) == [
      "car care", "car race"
    ])
  end
end
