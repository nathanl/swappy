defmodule Anagram.DictionaryTest do
  use ExUnit.Case
  doctest Anagram

  test "can map dictionary words by character list" do
    actual = Anagram.Dictionary.to_dictionary(["bat", "tab", "hat"])
    expected = %{
      [:a, :b, :t] => ["tab", "bat"],
      [:a, :h, :t] => ["hat"],
    }
    assert actual == expected
  end

end

