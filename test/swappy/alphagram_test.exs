defmodule Swappy.AlphagramTest do
  use ExUnit.Case
  doctest Swappy.Alphagram

  test "converting a string to an alphagram" do
    assert Swappy.Alphagram.to_alphagram("nappy") == 'anppy'
  end

  test "converting a string to an alphagram and removing illegal codepoints" do
    # Assumes default legal codepoints
    assert Swappy.Alphagram.to_alphagram("nappy?!!") == 'anppy'

    legal_codepoints  = 'bcdefghijklmnopqrstuvwxyz'
    assert Swappy.Alphagram.to_alphagram("nappy?!!", legal_codepoints) == 'nppy'

    assert Swappy.Alphagram.to_alphagram("nappy?!!", 'ap') == 'app'
  end

  test "subtracting nothing from a list" do
    assert Swappy.Alphagram.without('a', [])         == {:ok, 'a', []}
  end

  test "subtracting everything from a one-item list" do
    assert Swappy.Alphagram.without('a', 'a')      == {:ok, [], 'a'}
  end

  test "subtracting everything from a multi-item list" do
    assert Swappy.Alphagram.without('aa', 'aa') == {:ok, [], 'aa'}
  end

  test "subtracting the first item from a list" do
    assert Swappy.Alphagram.without('aa', 'a')      == {:ok, 'a', 'a'}
  end

  test "subtracting some items from different parts of a list" do
    assert Swappy.Alphagram.without('abcd', 'bd') == {:ok, 'ac', 'bd'}
  end

  test "trying to subtract an item that's not in the list" do
    assert Swappy.Alphagram.without(
      'ab', 'x'
    ) == {:error, "outer does not contain all letters of inner", {'ab', 'x'}}
  end

end
