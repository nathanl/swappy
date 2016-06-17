# Swappy

Elixir anagram generator. Basic usage:

    defmodule MyAnagramGenerator do
      use Swappy
    end

    anagrams = MyAnagramGenerator.anagrams_of(some_string) # uses a default wordlist
    # or
    anagrams = MyAnagramGenerator.anagrams_of(some_string, some_wordlist)

`some_wordlist` should be a list of words you consider valid.

## Custom Wordlists

If you want your module to use one or more custom word lists, define a `wordlists` method that returns a map. One of the map keys should be `:default`, and each value should be a list of words.

Your wordlist has to undergo some processing before it can be used to build anagrams. If you're going to use large custom wordlist, you probably want to do that processing at compile time, not at runtime.

You can do that as follows:

    defmodule SwappyUser do
      use Swappy
      @wordlists Swappy.Dictionary.load_files(
        %{
          default:   "/path/to/some_dictionary",
          alternate: "~/path/to/other_dictionary"
         }
      )
      def wordlists do
        @wordlists
      end
  end

## About the Wordlist

The wordlist you use has a huge effect on the number and quality of your anagrams, as well as the time it takes to generate them.

Some possible starting wordlists can be found at:

 - http://www-01.sil.org/linguistics/wordlists/english/
 - https://github.com/first20hours/google-10000-english
 - http://norvig.com/ngrams/

However, you probably want to clean up whatever you use. In particular, **every short word you supply vastly increases the number of anagrams generated**. You want as few 1-letter and 2-letter words as you can have.

Some wordlists include things 'r' as a word, on the grounds that you can say "The word 'rake' starts with 'r'." However, having every individual letter considered a "word" makes the number of possible anagrams astronomical.

See `Mix.Tasks.CleanUpEnglishDictionary` for an opinionated filter, then make your own if you wish.

## `legal_codepoint?(codepoint)`

TODO - explain

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

