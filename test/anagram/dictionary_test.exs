defmodule Anagram.DictionaryTest do
  use ExUnit.Case
  doctest Anagram

  test "can map dictionary words by character list" do
    actual = Anagram.Dictionary.to_dictionary(["bat", "tab", "hat"])
    expected = %{
      'abt' => ["tab", "bat"],
      'aht' => ["hat"],
    }
    assert actual == expected
  end

end

