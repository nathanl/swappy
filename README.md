# Anagrams

Elixir anagram generator. Usage:

    anagrams = Anagrams.for(some_string, some_dictionary)

`some_dictionary` should be a list of words you consider valid.

## About the Dictionary

The dictionary you use has a huge effect on the number and quality of your anagrams, as well as the time it takes to generate them.

Some dictionaries list things like 'r' as a word, on the grounds that you can say "The word 'rake' starts with 'r'." However, having every individual letter considered a "word" makes the number of possible anagrams astronomical.

Personally, I throw out most one- and two-letter "words" from my dictionaries, along with anything containing apostrophes.

A decent starting dictionary is: http://www-01.sil.org/linguistics/wordlists/english/

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

