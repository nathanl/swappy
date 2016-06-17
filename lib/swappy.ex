require Swappy.Alphagram
defmodule Swappy do
  def default_dict_file do
    "#{Path.dirname(__ENV__.file)}/default_wordlist.txt"
  end

  defmacro __using__(_) do
    quote do

      their_wordlists = Module.get_attribute(__MODULE__, :wordlists)
      if their_wordlists == nil do
        @wordlists Swappy.Dictionary.load_files(%{default: Swappy.default_dict_file})
      else
        @wordlists their_wordlists
      end
      their_legal_codepoints = Module.get_attribute(__MODULE__, :legal_codepoints)
      if their_legal_codepoints == nil do
        @legal_codepoints Swappy.Alphagram.default_legal_codepoints
      else
        @legal_codepoints their_legal_codepoints
      end

      @compiled_dictionaries (for {k, v} <- @wordlists, into: %{} do
        {k, Swappy.Dictionary.to_dictionary(v, @legal_codepoints)}
      end)
      def dictionaries do
        @compiled_dictionaries
      end

      def anagrams_of(phrase) do
        anagrams_of(phrase, :default)
      end

      def anagrams_of(phrase, dictionary_name) when is_atom(dictionary_name) do
        case Map.fetch(dictionaries, dictionary_name) do
          :error ->
            raise "Cannot find dictionary named #{inspect dictionary_name} in map returned from `dictionaries`"
          {:ok, dictionary} ->
            anagrams_of(phrase, dictionary)
        end
      end

      # Top level function
      # phrase is a string
      # wordlist is a list of strings
      def anagrams_of(phrase, wordlist) when is_list(wordlist) do
        dict          = Swappy.Dictionary.to_dictionary(wordlist, @legal_codepoints)
        anagrams_of(phrase, dict)
      end

      def anagrams_of(phrase, dict) do
        possible_words  = Map.keys(dict) |> Enum.sort # for deterministic test output
        initial_bag = Swappy.Alphagram.to_alphagram(phrase, @legal_codepoints)
        # anagrams = Swappy.generate_anagrams(initial_bag, possible_words)
        anagrams = Swappy.Queue.process([found: [], bag: initial_bag, possible_words: possible_words])
        anagrams |> Enum.map(&Swappy.human_readable(&1, dict)) |> List.flatten
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

  def anagrams_for_words_and_bags({[word|words_t]=words, [bag|bags_t]=_bags}, acc) do
    newly_found_anagrams = case bag do
      [] -> 
        # found a leaf
        [ [word] ]
      _ ->
        # search downward in the anagram tree
        anagrams_without_word = Swappy.generate_anagrams(bag, words)
        Enum.map(anagrams_without_word, &([word|&1]))
    end

    # keep moving right through the anagram tree
    anagrams_for_words_and_bags({words_t, bags_t}, newly_found_anagrams ++ acc)
  end

  def process_one_job([found: found, bag: [], possible_words: _]) do
    {:anagram, found}
  end
  def process_one_job([found: found, bag: bag, possible_words: possible_words]) do
    {:more_jobs, create_jobs(bag, possible_words, found)}
  end

  def create_jobs(bag, possible_words, found) do
    {words, bags} = find_words(bag, possible_words)
    jobs(words, bags, found, [])
  end

  def jobs([]=_words, []=_bags, _found, acc), do: acc
  def jobs([word|words_t]=words, [bag|bags_t], found, acc) do
    one_job = [ found: [word|found], bag: bag, possible_words: words ]
    jobs(words_t, bags_t, found, [one_job|acc])
  end

  def find_words(bag, possible_words) do
    possible_words
    |> Enum.reduce({[], []}, fn (possible_word, {words, bags}) ->
      case Swappy.Alphagram.without(bag, possible_word) do
        {:ok, remaining_bag, word} -> { [word|words], [remaining_bag|bags] }
        _ -> {words, bags}
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
