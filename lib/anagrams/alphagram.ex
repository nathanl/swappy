defmodule Anagrams.Alphagram do

  def contains?(outer, inner) do
    (without(outer, inner, []) |> elem(0)) == :ok
  end

  # *** This function relies on knowledge that alphagrams are sorted ***
  def without(outer, inner) do
    case without(outer, inner, []) do
      {:ok, acc} ->
        acc |> :lists.reverse
      {:error, message} ->
        {:error, message}
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
    {:error, "some letters in inner are not in outer"}
  end

  # We've run past the point where we can find what we're looking for
  def without([outer_h | _outer_t], [inner_h | _inner_t], _acc) when outer_h  > inner_h do
    {:error, "some letters in inner are not in outer"}
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
