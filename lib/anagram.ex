defmodule Anagram do

  defmacro __using__(_) do
    quote do

      def of(phrase) do
        of(phrase, :default)
      end

      def of(phrase, dictionary_name) when is_atom(dictionary_name) do
        if is_nil(dictionaries) do
          raise "No dictionaries returned from function dictionaries/0"
        end
        case Map.fetch(dictionaries, dictionary_name) do
          :error ->
            raise "Cannot find dictionary named #{inspect dictionary_name} in :dictionary_files environment variable - see README and config.exs"
          {:ok, dictionary} ->
            of(phrase, dictionary)
        end
      end

      def dictionaries do
        nil
      end

      # Top level function
      # phrase is a string
      # human_readable_dictionary is a set of strings
      def of(phrase, human_readable_dictionary) do
        dict          = dictionary(human_readable_dictionary)
        dict_entries  = Map.keys(dict) # TODO - make this ordered like input dict
        anagrams = anagrams_for(alphagram(phrase), dict_entries)
        anagrams |> Enum.map(&human_readable(&1, dict)) |> List.flatten
      end

      def legal_codepoints do
        97..122 # lowercase a..z
      end

      # Sorted, non-unique list of codepoints
      # "alpha" -> ["a", "a", "h", "l", "p"]
      def alphagram(string) do
        string
        |> String.downcase
        |> String.codepoints
        |> Enum.reject(fn(codepoint) ->
          <<codepoint_val::utf8>> = codepoint
          !(codepoint_val in legal_codepoints)
        end)
        |> Enum.sort
      end

      # returns map with entries like ["d", "g", "o"] => ["god", "dog"]
      def dictionary(human_readable_dictionary) do
        Enum.reduce(human_readable_dictionary, %{}, fn word, map_acc ->
          word = String.strip(word)
          if word == "" do
            map_acc
          else
            # If key isn't found, the value passed to our function is 'nil'
            update_in(map_acc, [alphagram(word)], &([word|(&1 || [])]))
          end
        end)
      end

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

        init_acc = %{dict: usable_entries, pids: []}
        %{pids: pids} = Enum.reduce(usable_entries, init_acc, fn(entry, acc) ->
          anagrams_without_entry = anagrams_for((phrase |> Anagram.Alphagram.without(entry)), acc.dict)
          result = Enum.map(anagrams_without_entry, &([entry | &1]))
          %{dict: tl(acc.dict), pids: result ++ acc.pids}
        end)

        pids
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
        Enum.filter(dict_entries, &(Anagram.Alphagram.contains?(phrase, &1)))
      end

      defoverridable [dictionaries: 0, legal_codepoints: 0]
    end

  end

end
