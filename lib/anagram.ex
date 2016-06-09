defmodule Anagram do
  @default_wordlists Anagram.Dictionary.load_files(%{default: "#{Path.dirname(__ENV__.file)}/common_words_dictionary.txt"})
  def default_wordlists do
    @default_wordlists
  end

  defmacro __using__(_) do
    quote do

      def of(phrase) do
        of(phrase, :default)
      end

      def of(phrase, dictionary_name) when is_atom(dictionary_name) do
        if :erlang.is_map(dictionaries) do
          case Map.fetch(dictionaries, dictionary_name) do
            :error ->
              raise "Cannot find dictionary named #{inspect dictionary_name} in map returned from `dictionaries`"
            {:ok, dictionary} ->
              of(phrase, dictionary)
          end
        else
          raise "No map of dictionaries was returned from function dictionaries/0 - see documentation"
        end
      end

      # TODO - find a way to process these with Anagram.Dictionary.to_dictionary at compile time
      def dictionaries do
        wordlists
      end

      # Top level function
      # phrase is a string
      # wordlist is a list of strings
      def of(phrase, wordlist) do
        dict          = Anagram.Dictionary.to_dictionary(wordlist, legal_codepoints)
        dict_entries  = Map.keys(dict) # TODO - make this ordered like input dict
        anagrams = Anagram.anagrams_for(Anagram.Alphagram.to_alphagram(phrase, legal_codepoints), dict_entries)
        anagrams |> Enum.map(&Anagram.human_readable(&1, dict)) |> List.flatten
      end

      def wordlists do
        Anagram.default_wordlists
      end

      def legal_codepoints do
        Anagram.Alphagram.legal_codepoints
      end

      defoverridable [wordlists: 0, legal_codepoints: 0]
    end

  end

  def anagrams_for([], _dict_entries) do
    [[]]
  end

  # catbat
  # set([["a", "b", "t"], ["a", "c", "t"]], ...)
  # phrase is a alphagram; dict_entries is a set of alphagrams
  # return a set of answers - each answer is a list of alphagrams,
  # each answer contains exactly the letters of the input phrase
  # dict_entries is an enumerable.
  # returns a Set.
  def anagrams_for(phrase, dict_entries) do
    usable_entries = usable_entries_for(dict_entries, phrase)

    init_acc = %{dict: usable_entries |> Enum.map(&elem(&1, 1)), results: []}
    %{results: results} = Enum.reduce(usable_entries, init_acc, fn({phrase_without_entry, entry}, acc) ->
      anagrams_without_entry = Anagram.anagrams_for(phrase_without_entry, acc.dict)

      new_results = Enum.reduce(anagrams_without_entry, acc.results, fn (anagram_without_entry, results) ->
        anagram_with_entry = [entry | anagram_without_entry]
        [anagram_with_entry | results]
      end)

      %{dict: tl(acc.dict), results: new_results}
    end)

    results
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
