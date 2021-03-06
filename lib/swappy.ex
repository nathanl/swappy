require Swappy.Alphagram

defmodule Swappy do
  defmacro __using__(_) do
    quote do
      @wordlists Swappy.Dictionary.add_wordlists(Module.get_attribute(__MODULE__, :wordlists))
      @legal_chars Swappy.Alphagram.set_legal_chars(
                     Module.get_attribute(__MODULE__, :legal_chars)
                   )

      @compiled_dictionaries (for {k, v} <- @wordlists, into: %{} do
                                {k, Swappy.Dictionary.to_dictionary(v, @legal_chars)}
                              end)
      def dictionaries do
        @compiled_dictionaries
      end

      @default_options %{wordlist: :default, dictionary: nil, limit: :infinity}

      def anagrams_of(phrase) do
        anagrams_of(phrase, @default_options)
      end

      def anagrams_of(phrase, %{wordlist: wordlist_name} = options) when is_atom(wordlist_name) do
        case Map.fetch(dictionaries(), wordlist_name) do
          {:ok, dictionary} ->
            new_options =
              options
              |> Map.delete(:wordlist)
              |> Map.put(:dictionary, dictionary)

            anagrams_of(phrase, new_options)

          :error ->
            raise "Cannot find wordlist named #{inspect(wordlist_name)} - known wordlists are #{
                    Map.keys(dictionaries())
                  }"
        end
      end

      # Top level function
      # phrase is a string
      # wordlist is a list of strings
      def anagrams_of(phrase, %{wordlist: wordlist} = options) when is_list(wordlist) do
        dict = Swappy.Dictionary.to_dictionary(wordlist, @legal_chars)
        remaining_options = Map.delete(options, :wordlist)
        options_with_dictionary = Map.put(remaining_options, :dictionary, dict)
        anagrams_of(phrase, options_with_dictionary)
      end

      def anagrams_of(phrase, %{dictionary: dict} = options) do
        options = Map.delete(options, :dictionary)
        possible_words = dict.ordered_alphagrams
        initial_bag = Swappy.Alphagram.to_alphagram(phrase, @legal_chars)
        # raw_anagrams = Swappy.generate_anagrams(initial_bag, possible_words)
        raw_anagrams =
          Swappy.Queue.process(
            [found: [], bag: initial_bag, possible_words: possible_words],
            options
          )

        anagrams =
          raw_anagrams |> Enum.map(&Swappy.human_readable(&1, dict.alphagram_map))
          |> List.flatten()

        if is_integer(Map.get(options, :limit)) do
          Enum.take(anagrams, Map.get(options, :limit))
        else
          anagrams
        end
      end

      def anagrams_of(phrase, options) do
        anagrams_of(phrase, Map.merge(@default_options, options))
      end
    end
  end

  # |bag| is a Scrabble tile bag full of tiles to make into an anagram.
  # |possible_words| are the words we *may* be able to extract from the bag.
  def generate_anagrams(bag, possible_words) do
    {words, bags} = find_words(bag, possible_words)
    anagrams_for_words_and_bags({words, bags}, [])
  end

  # completely done moving right through the anagram tree
  def anagrams_for_words_and_bags({[], []}, acc), do: acc

  def anagrams_for_words_and_bags({[word | words_t] = words, [bag | bags_t] = _bags}, acc) do
    newly_found_anagrams =
      case bag do
        [] ->
          # found a leaf
          [[word]]

        _ ->
          # search downward in the anagram tree
          anagrams_without_word = Swappy.generate_anagrams(bag, words)
          Enum.map(anagrams_without_word, &[word | &1])
      end

    # keep moving right through the anagram tree
    anagrams_for_words_and_bags({words_t, bags_t}, newly_found_anagrams ++ acc)
  end

  # There are no more letters left in the bag, so "process" this job by simply
  # declaring whatever has been found to be an anagram
  def process_one_job(found: found, bag: [], possible_words: _) do
    {:anagram, found}
  end

  # Since there are letters left in the bag, we should try some more ways of
  # finding words
  def process_one_job(found: found, bag: bag, possible_words: possible_words) do
    {:more_jobs, create_jobs(bag, possible_words, found)}
  end

  def create_jobs(bag, possible_words, found) do
    {words, bags} = find_words(bag, possible_words)
    jobs(words, bags, found, [])
  end

  def jobs([] = _words, [] = _bags, _found, acc) do
    # jobs should be ordered like the wordlist for priority's sake
    :lists.reverse(acc)
  end

  def jobs([word | words_t] = words, [bag | bags_t], found, acc) do
    one_job = [found: [word | found], bag: bag, possible_words: words]
    jobs(words_t, bags_t, found, [one_job | acc])
  end

  # For every remaining possible word...
  # - if it can't be spelled using the letters left in the bag, discard it
  # - if it can be, add it to the words we've found, and add a bag that is the
  # old bag minus this word's letters
  def find_words(bag, possible_words) do
    filtered_words_and_bags =
      possible_words
      |> Enum.reduce({[], []}, fn possible_word, {words, bags} ->
        case Swappy.Alphagram.without(bag, possible_word) do
          {:ok, remaining_bag, word} -> {[word | words], [remaining_bag | bags]}
          _ -> {words, bags}
        end
      end)

    # Restore original order from wordlist
    words = :lists.reverse(elem(filtered_words_and_bags, 0))
    bags = :lists.reverse(elem(filtered_words_and_bags, 1))
    {words, bags}
  end

  # Convert a list of alphagrams to a list of human-readable anagrams
  # e.g. [ alphagram("race"), alphagram("car") ] =>
  # [ "care car", "race car" ]
  def human_readable(anagram, dictionary) do
    anagram
    |> Enum.map(&dictionary[&1])
    |> cartesian_product
    |> Enum.map(&Enum.join(&1, " "))
  end

  # cartesian_prod([0..2, 0..1, 0..2]) = [000, 001, 002, 010, 011, 012, 100...]
  def cartesian_product([]), do: []

  def cartesian_product(lists) do
    Enum.reduce(lists, [[]], fn one_list, acc ->
      for item <- one_list,
          subproduct <- acc,
          do: [item | subproduct]
    end)
  end
end
