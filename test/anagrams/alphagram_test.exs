defmodule Anagrams.AlphagramTest do
  use ExUnit.Case
  doctest Anagrams.Alphagram

  test "contains?" do
    assert Anagrams.Alphagram.contains?(["a", "b"],      ["a"])      == true
    assert Anagrams.Alphagram.contains?(["a", "b"],      ["b"])      == true
    assert Anagrams.Alphagram.contains?(["a", "b"],      ["c"])      == false
    assert Anagrams.Alphagram.contains?(["a", "b"],      ["a", "b"]) == true
    assert Anagrams.Alphagram.contains?(["a", "g"],      ["a", "b"]) == false
    assert Anagrams.Alphagram.contains?(["a", "b"],      ["a", "a"]) == false
    assert Anagrams.Alphagram.contains?(["a", "a", "b"], ["a", "a"]) == true
    assert Anagrams.Alphagram.contains?(["a", "b"],      [])         == true
    assert Anagrams.Alphagram.contains?([],              ["a", "b"]) == false
  end

  test "without" do
    assert Anagrams.Alphagram.without(["a"                ], [])         == ["a"]
    assert Anagrams.Alphagram.without(["a"                ], ["a"])      == []
    assert Anagrams.Alphagram.without(["a", "a"           ], ["a"])      == ["a"]
    assert Anagrams.Alphagram.without(["a", "a"           ], ["a", "a"]) == []
    assert Anagrams.Alphagram.without(["a", "b", "c", "d" ], ["b", "c"]) == ["a", "d"]
  end

end
