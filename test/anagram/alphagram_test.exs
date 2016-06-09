defmodule Anagram.AlphagramTest do
  use ExUnit.Case
  doctest Anagram.Alphagram

  test "without" do
    assert Anagram.Alphagram.without(["a"                ], [])         == {:ok, ["a"], []}
    assert Anagram.Alphagram.without(["a"                ], ["a"])      == {:ok, [], ["a"]}
    assert Anagram.Alphagram.without(["a", "a"           ], ["a"])      == {:ok, ["a"], ["a"]}
    assert Anagram.Alphagram.without(["a", "a"           ], ["a", "a"]) == {:ok, [], ["a", "a"]}
    assert Anagram.Alphagram.without(["a", "b", "c", "d" ], ["b", "c"]) == {:ok, ["a", "d"], ["b", "c"]}
    assert Anagram.Alphagram.without(
      ["a", "b"], ["x"]
    ) == {:error, "outer does not contain all letters of inner", {["a", "b"], ["x"]}}
  end

end
