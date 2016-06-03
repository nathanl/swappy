defmodule AnagramsTest do
  Code.load_file("configured_anagrams.ex", "test")
  use ExUnit.Case
  doctest Anagrams

  test "can find the only possible anagrams using a tiny dictionary" do
    result = ConfiguredAnagrams.of("onto", ["on", "to"])
    assert result == ["to on"]
  end

  test "ignores punctuation, capitalization and spaces" do
    result = ConfiguredAnagrams.of("On, To!", ["on", "to"])
    assert result == ["to on"]
  end

  test "can find human-readable anagrams of a phrase using a dictionary" do
    result = ConfiguredAnagrams.of("racecar", ["arc", "are", "car", "care", "race"])
    assert result == ["arc care", "arc race", "car care", "car race"]
  end

  test "can handle duplicate words in the input phrase" do
    result = ConfiguredAnagrams.of("apple racecar apple", ["race", "car", "apple", "racecar"])
    assert result == ["apple apple car race", "apple apple racecar"]
  end

  test "can convert a string to sorted codepoints" do
    assert ConfiguredAnagrams.alphagram("nappy") == ["a", "n", "p", "p", "y"]
  end

  test "can map dictionary words by character list" do
    actual = ConfiguredAnagrams.dictionary(["bat", "tab", "hat"])
    expected = %{
      ["a", "b", "t"] => ["tab", "bat"],
      ["a", "h", "t"] => ["hat"],
    }
    assert actual == expected
  end

  test "human_readable builds a 'cartesian join' of words the alphagrams can spell" do
    anagram = [["a","c","e","r"], ["a","c","r"]]
    dictionary = %{
      ["a", "c", "e", "r"] => ["race", "care"],
      ["a", "c", "r"] => ["car"],
    }
    assert((ConfiguredAnagrams.human_readable(anagram, dictionary) |> Enum.sort) == [
      "car care", "car race"
    ])
  end
end
