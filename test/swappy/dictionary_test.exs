defmodule Swappy.DictionaryTest do
  use ExUnit.Case
  doctest Swappy

  test "can map dictionary words by character list" do
    actual = Swappy.Dictionary.to_dictionary(["bat", "tab", "hat"])
    expected = %Swappy.Dictionary{
      alphagram_map: %{
        'abt' => ["tab", "bat"],
        'aht' => ["hat"],
      },
      ordered_alphagrams: ['abt', 'aht']
    }
    assert actual == expected
  end

end

