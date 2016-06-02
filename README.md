# Anagrams

Elixir anagram generator. Basic usage:

    anagrams = Anagrams.for(some_string, some_dictionary)

`some_dictionary` should be a list of words you consider valid.

If you configure one or more dictionaries in `config.exs`:

    config :anagrams,
      dictionary_files: %{default: "/path/to/file.txt", alt_dict: "/other/file.txt"},

... you can do this:

    anagrams = Anagrams.for(some_string, :alt_dict)
    anagrams = Anagrams.for(some_string) # assumes :default

**Note: configuration and dictionary files are read at compile time, so if you change them, you must recompile to see the changes.**

## About the Dictionary

The dictionary you use has a huge effect on the number and quality of your anagrams, as well as the time it takes to generate them.

A decent starting dictionary is: http://www-01.sil.org/linguistics/wordlists/english/

However, you probably want to clean up whatever you use.

Some dictionaries list things like 'r' as a word, on the grounds that you can say "The word 'rake' starts with 'r'." However, having every individual letter considered a "word" makes the number of possible anagrams astronomical.

Personally, I throw out most one- and two-letter "words" from my dictionaries, along with anything containing apostrophes. You could do that like this:

    words |> Enum.filter(fn (word) ->
      cond do
        String.length(word) < 2 && !word in ~w(a i o) -> false
        String.length(word) == 2 && (!word in ~w(ad ah ai am an as at aw ax ay be bi by do eh er ex go ha he hi ho id if in is it la lo ma me my of oh on or ow ox oy pa pH pi qi re so to um up us we ye yo)) -> false
        true -> true
      end
    end)

## TODO

- http://stackoverflow.com/questions/37601658/how-can-i-get-my-library-code-to-recompile-if-the-application-environment-change
- Stop having Anagrams.Dictionary prune the incoming words
- Ensure that if the dictionary file changes, it triggers a recompile
- Cleanup and documentation
- Release
- Make parallelization less hacky.
  - Idea: each phrase/dictionary lookup becomes a job in a queue, with jobs farmed out to N workers, who can send back "partially digested" jobs for reassignment or complete jobs to be added to results. When no jobs remain and no workers are still working, results are complete. This is way more complicated than what we're doing now, and we're probably already getting as much speedup from parallelization as we can get, given that we have more processes than cores on a typical machine and the work is CPU-bound, so it may not be worthwhile.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add anagrams to your list of dependencies in `mix.exs`:

        def deps do
          [{:anagrams, "~> 0.0.1"}]
        end

  2. Ensure anagrams is started before your application:

        def application do
          [applications: [:anagrams]]
        end

