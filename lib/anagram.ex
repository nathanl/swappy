defmodule Anagram do
  @default_wordlists Anagram.Dictionary.load_files(%{default: "#{Path.dirname(__ENV__.file)}/common_words_dictionary.txt"})
  def default_wordlists do
    @default_wordlists
  end
  #        dict          = Anagram.Dictionary.to_dictionary(wordlist, &legal_codepoint?/1)

  defmacro __using__(using_opts) do
    quote do

      IO.puts "TODO FIX THIS THX"
      # if using_opts.wordlists is not the right format
      #   raise "No map of dictionaries was returned from function dictionaries/0 - see documentation"
      # end

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
        dict          = Anagram.Dictionary.to_dictionary(wordlist, &legal_codepoint?/1)
        anagrams_of(phrase, dict)
      end

      def anagrams_of(phrase, dict) do
        possible_words  = Map.keys(dict) |> Enum.sort # for deterministic test output
        initial_bag = Anagram.Alphagram.to_alphagram(phrase, &legal_codepoint?/1)
        # anagrams = Anagram.generate_anagrams(initial_bag, possible_words)
        anagrams = Anagram.Queue.process([found: [], bag: initial_bag, possible_words: possible_words])
        anagrams |> Enum.map(&Anagram.human_readable(&1, dict)) |> List.flatten
      end

      def legal_codepoint?(codepoint) do
        # func = Keyword.get(unquote(using_opts), :legal_codepoint?, Anagram.Alphagram.legal_codepoint?/1)
        # func(codepoint)
        Anagram.Alphagram.legal_codepoint?(codepoint)
      end

      # def wordlists do
      #   Keyword.get(unquote(using_opts), :wordlists, @default_wordlists)
      # end
      # @legal_codepoint_func Keyword.get(unquote(using_opts), :legal_codepoint?, Anagram.Alphagram.legal_codepoint?/1)

      @compiled_dictionaries (for {k, v} <- Keyword.get(unquote(using_opts), :wordlists, Anagram.default_wordlists), into: %{} do
        {k, Anagram.Dictionary.to_dictionary(v)}
      end)
      def dictionaries do
        @compiled_dictionaries
      end


      defoverridable [legal_codepoint?: 1]
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
        anagrams_without_word = Anagram.generate_anagrams(bag, words)
        Enum.map(anagrams_without_word, &([word|&1]))
    end

    # keep moving right through the anagram tree
    anagrams_for_words_and_bags({words_t, bags_t}, newly_found_anagrams ++ acc)
  end

  # TODO temp code to test create_jobs
  # We could put an accumulator on process_queue to accumulate found anagrams.
  # But we want to send them to some supervisor one at a time, right?
  def process_queue([], _, anagram_count, _dictionary) do
    IO.puts("All done with #{anagram_count} anagrams")
  end
  def process_queue([job|rest_of_jobs], n, anagram_count, dictionary) do
    case process_one_job(job) do
      {:anagram, found} -> 
        count = emit_anagrams(found, dictionary, anagram_count)
        process_queue(rest_of_jobs, n-1, anagram_count+count, dictionary)
      {:more_jobs, new_jobs} -> 
        process_queue(new_jobs ++ rest_of_jobs, n-1 + Enum.count(new_jobs), anagram_count, dictionary)
    end
  end

  def process_one_job([found: found, bag: [], possible_words: _]) do
    {:anagram, found}
  end
  def process_one_job([found: found, bag: bag, possible_words: possible_words]) do
    {:more_jobs, create_jobs(bag, possible_words, found)}
  end
  def emit_anagrams(found, dictionary, _n) do
    #TODO we already have a function that does this
    #TODO we could 'send' this to a supervisor instead
    anagrams = human_readable found, dictionary
    #anagrams |> Enum.each(&(IO.puts "Anagram group #{n}: #{&1}"))
    Enum.count anagrams
  end
  #TODO end temp code

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
      case Anagram.Alphagram.without(bag, possible_word) do
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
