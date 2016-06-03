defmodule AnagramTest do
  Code.load_file("configured_anagram.ex", "test")
  use ExUnit.Case
  doctest Anagram

  test "can find the only possible anagrams using a tiny dictionary" do
    result = ConfiguredAnagram.of("onto", ["on", "to"])
    assert result == ["to on"]
  end

  test "ignores punctuation, capitalization and spaces" do
    result = ConfiguredAnagram.of("On, To!", ["on", "to"])
    assert result == ["to on"]
  end

  test "can find human-readable anagrams of a phrase using a dictionary" do
    result = ConfiguredAnagram.of("racecar", ["arc", "are", "car", "care", "race"])
    assert result == ["arc care", "arc race", "car care", "car race"]
  end

  test "can handle duplicate words in the input phrase" do
    result = ConfiguredAnagram.of("apple racecar apple", ["race", "car", "apple", "racecar"])
    assert result == ["apple apple car race", "apple apple racecar"]
  end

  test "can convert a string to sorted codepoints" do
    assert ConfiguredAnagram.alphagram("nappy") == ["a", "n", "p", "p", "y"]
  end

  test "can map dictionary words by character list" do
    actual = ConfiguredAnagram.dictionary(["bat", "tab", "hat"])
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
    assert((ConfiguredAnagram.human_readable(anagram, dictionary) |> Enum.sort) == [
      "car care", "car race"
    ])
  end
end
