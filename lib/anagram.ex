defmodule Anagram do
  @default_wordlists Anagram.Dictionary.load_files(%{default: "#{Path.dirname(__ENV__.file)}/common_words_dictionary.txt"})
  def default_wordlists do
    @default_wordlists
  end

  defmacro __using__(_) do
    quote do

      def anagrams_of(phrase) do
        anagrams_of(phrase, :default)
      end

      def anagrams_of(phrase, dictionary_name) when is_atom(dictionary_name) do
        if :erlang.is_map(dictionaries) do
          case Map.fetch(dictionaries, dictionary_name) do
            :error ->
              raise "Cannot find dictionary named #{inspect dictionary_name} in map returned from `dictionaries`"
            {:ok, dictionary} ->
              anagrams_of(phrase, dictionary)
          end
        else
          raise "No map of dictionaries was returned from function dictionaries/0 - see documentation"
        end
      end

      # Top level function
      # phrase is a string
      # wordlist is a list of strings
      def anagrams_of(phrase, wordlist) do
        dict          = Anagram.Dictionary.to_dictionary(wordlist, &legal_codepoint?/1)
        dict_entries  = Map.keys(dict) # TODO - make this ordered like input dict
        phrase_alphagram = Anagram.Alphagram.to_alphagram(phrase, &legal_codepoint?/1)
        usable_entries = Anagram.usable_entries_for(dict_entries, phrase_alphagram)
        anagrams = Anagram.of(usable_entries, [])
        anagrams |> Enum.map(&Anagram.human_readable(&1, dict)) |> List.flatten
      end

      # TODO - find a way to process these with Anagram.Dictionary.to_dictionary at compile time
      def dictionaries do
        wordlists
      end

      def wordlists do
        Anagram.default_wordlists
      end

      def legal_codepoint?(codepoint) do
        Anagram.Alphagram.legal_codepoint?(codepoint)
      end

      defoverridable [wordlists: 0, legal_codepoint?: 1]
    end

  end

  # completely done moving right through the anagram tree
  def of([], acc), do: acc

  def of([{phrase_without_entry, entry}|rest]=usable_entries, acc) do
    dict_entries = usable_entries |> Enum.map(&elem(&1, 1))

    newly_found_anagrams = case phrase_without_entry do
      [] -> 
        # found a leaf
        [ [entry] ]
      _ ->
        # search downward in the anagram tree
        anagrams_without_entry = Anagram.of(usable_entries_for(dict_entries, phrase_without_entry), [])
        Enum.map(anagrams_without_entry, &([entry|&1]))
    end

    # keep moving right through the anagram tree
    Anagram.of(rest, newly_found_anagrams ++ acc)
  end

  def usable_entries_for(dict_entries, phrase) do
    dict_entries
    |> Enum.reduce([], fn (entry, acc) ->
      case Anagram.Alphagram.without(phrase, entry) do
        {:ok, outer, inner} -> [ {outer, inner} | acc]
        _ -> acc
      end
    end)
  end

  # Convert a list of alphagrams to a list of human-readable anagrams
  # e.g. [ alphagram("race"), alphagram("car") ] =>
  # [ "care car", "race car" ]
  def human_readable(anagram, dictionary) do
    anagram
    |> Enum.map(&(dictionary[&1]))
    |> cartesian_product
    |> Enum.map(&Enum.join(&1, " "))
  end

  # cartesian_prod([0..2, 0..1, 0..2]) = [000, 001, 002, 010, 011, 012, 100...]
  def cartesian_product([]), do: []
  def cartesian_product(lists) do
    Enum.reduce(lists, [ [] ], fn one_list, acc ->
      for item <- one_list, subproduct <- acc, do: [item | subproduct]
    end)
  end

end
