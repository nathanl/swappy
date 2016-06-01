defmodule Anagrams do
  @legal_codepoints 97..122 # lowercase a..z

  # Top level function
  # phrase is a string
  # human_readable_dictionary is a set of strings
  def for(phrase, human_readable_dictionary) do
    dict          = dictionary(human_readable_dictionary)
    dict_entries  = Map.keys(dict)
    anagrams = anagrams_for(alphagram(phrase), dict_entries)
    anagrams |> Enum.map(&human_readable(&1, dict)) |> List.flatten
  end

  # Takes a filename, returns list with one string per non-empty line
  def load_human_readable_dictionary(filename) do
    File.stream!(filename)
    |> Enum.map(&String.strip/1)
    # Throw out a bunch of tiny garbage "words" which vastly increase the
    # number of anagrams if included
    |> Enum.filter(fn (word) ->
      cond do
        String.length(word) < 2 && !word in ~w(a i o) -> false
        String.length(word) == 2 && (!word in ~w(ad ah ai am an as at aw ax ay be bi by do eh er ex go ha he hi ho id if in is it la lo ma me my of oh on or ow ox oy pa pH pi qi re so to um up us we ye yo)) -> false
        true -> true
      end
    end)
  end

  # Sorted, non-unique list of codepoints
  # "alpha" -> ["a", "a", "h", "l", "p"]
  def alphagram(string) do
    string
    |> String.downcase
    |> String.codepoints
    |> Enum.reject(fn(codepoint) ->
      <<codepoint_val::utf8>> = codepoint
      !(codepoint_val in @legal_codepoints)
    end)
    |> Enum.sort
  end

  # returns map with entries like ["d", "g", "o"] => ["god", "dog"]
  def dictionary(human_readable_dictionary) do
    Enum.reduce(human_readable_dictionary, %{}, fn word, map_acc ->
      # If key isn't found, the value passed to our function is 'nil'
      update_in(map_acc, [alphagram(word)], &([word|(&1 || [])]))
    end)
  end

  # define base case
  defp anagrams_for([], _dict_entries) do
    [[]]
  end

  defp anagrams_for(_phrase, []) do
    [[]]
  end

  # catbat
  # set([["a", "b", "t"], ["a", "c", "t"]], ...)
  # phrase is a alphagram; dict_entries is a set of alphagrams
  # return a set of answers - each answer is a list of alphagrams,
  # each answer contains exactly the letters of the input phrase
  # dict_entries is an enumerable.
  # returns a Set.
  defp anagrams_for(phrase, dict_entries) do
    usable_entries = usable_entries_for(dict_entries, phrase)

    init_acc = %{dict: usable_entries, anagrams: []}
    %{anagrams: answer} = Enum.reduce(usable_entries, init_acc, fn(entry, acc) ->
      anagrams_without_entry = anagrams_for((phrase |> without(entry)), acc.dict)
      anagrams_with_entry = Enum.map(anagrams_without_entry, &([entry | &1]))
      %{dict: tl(acc.dict), anagrams: anagrams_with_entry ++ acc.anagrams}
    end)

    answer
  end

  # Convert a list of alphagrams to a list of human-readable anagrams
  # e.g. [ alphagram("race"), alphagram("car") ] =>
  # [ "care car", "race car" ]
  def human_readable(anagram, dictionary) do
    anagram
    |> Enum.map(&(dictionary[&1]))
    |> cartesian_product
    |> Enum.map(&Enum.join(&1, " "))
    |> Enum.sort
  end

  # cartesian_prod([0..2, 0..1, 0..2]) = [000, 001, 002, 010, 011, 012, 100...]
  def cartesian_product([]), do: []
  def cartesian_product(lists) do
    Enum.reduce(lists, [ [] ], fn one_list, acc ->
      for item <- one_list, subproduct <- acc, do: [item | subproduct]
    end)
  end

  def usable_entries_for(dict_entries, phrase) do
    Enum.filter(dict_entries, &(contains?(phrase, &1)))
  end

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
