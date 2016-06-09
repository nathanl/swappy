defmodule Anagram.AlphagramTest do
  use ExUnit.Case
  doctest Anagram.Alphagram

  test "subtracting nothing from a list" do
    assert Anagram.Alphagram.without(["a"                ], [])         == {:ok, ["a"], []}
  end

  test "subtracting everything from a one-item list" do
    assert Anagram.Alphagram.without(["a"                ], ["a"])      == {:ok, [], ["a"]}
  end

  test "subtracting everything from a multi-item list" do
    assert Anagram.Alphagram.without(["a", "a"           ], ["a", "a"]) == {:ok, [], ["a", "a"]}
  end

  test "subtracting the first item from a list" do
    assert Anagram.Alphagram.without(["a", "a"           ], ["a"])      == {:ok, ["a"], ["a"]}
  end

  test "subtracting some items from different parts of a list" do
    assert Anagram.Alphagram.without(["a", "b", "c", "d" ], ["b", "d"]) == {:ok, ["a", "c"], ["b", "d"]}
  end

  test "trying to subtract an item that's not in the list" do
    assert Anagram.Alphagram.without(
      ["a", "b"], ["x"]
    ) == {:error, "outer does not contain all letters of inner", {["a", "b"], ["x"]}}
  end

end
