defmodule Anagram.Alphagram do

  @default_legal_codepoints 'abcdefghijklmnopqrstuvwxyz'
  def default_legal_codepoints do
    @default_legal_codepoints
  end

  # Convenience for to_alphagram/2; uses default list
  def to_alphagram(string) do
    to_alphagram(string, default_legal_codepoints)
  end

  # Sorted, non-unique list of codepoints
  # "alpha" -> 'aahlp'
  def to_alphagram(string, legal_codepoints) do
    string
    |> String.downcase
    |> String.to_char_list
    |> Enum.filter(&(&1 in legal_codepoints))
    |> Enum.sort
  end

  # *** This function relies on knowledge that alphagrams are sorted ***
  def without(outer, inner) do
    case without(outer, inner, []) do
      {:ok, acc} ->
        {:ok, (acc |> :lists.reverse), inner}
      {:error, message} ->
        {:error, message, {outer, inner}}
    end
  end

  # We've looked through everything and may have results
  def without([] = _outer, [] = _inner, acc) do
    {:ok, acc}
  end

  # We've filtered out inner, so just grab the rest of the letters from outer
  def without([h | t] = _outer, [] = _inner, acc) do
    without(t, [], [h | acc])
  end

  def without([] = _outer, _inner, _acc) do
    {:error, "outer does not contain all letters of inner"}
  end

  # We've run past the point where we can find what we're looking for
  def without([outer_h | _outer_t], [inner_h | _inner_t], _acc) when outer_h  > inner_h do
    {:error, "outer does not contain all letters of inner"}
  end

  # heads match - this is a letter we want to remove
  def without([outer_h | outer_t], [inner_h | inner_t], acc)    when outer_h == inner_h do
    without(outer_t, inner_t, acc)
  end

  # Keep this letter from outer and keep looking for others to filter out
  def without([outer_h | outer_t], [inner_h | inner_t], acc)    when outer_h  < inner_h do
    without(outer_t, [inner_h | inner_t], [outer_h | acc])
  end

end
