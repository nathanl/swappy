# Swappy

Elixir anagram generator.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add swappy to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:swappy, "~> 0.0.1"}]
end
```

  2. Ensure swappy is started before your application:

```elixir
def application do
  [applications: [:swappy]]
end
```

## Basic Usage

```elixir
defmodule MyAnagramGenerator do
  use Swappy
end

anagrams = MyAnagramGenerator.anagrams_of(some_string) # uses a default wordlist
# or
anagrams = MyAnagramGenerator.anagrams_of(some_string, some_wordlist)
```

`some_wordlist` should be a list of words you consider valid. This is fine for playing around in the console, but since your wordlist requires some processing before Swappy can use it to generate anagrams, you'll get better performance if you let Swappy do that at compilation time.

## Compiling Custom Wordlists

If you want your module to use one or more custom word lists, set `@wordlists` in your module to be a map of wordlists before calling `use Swappy`.

The keys of your map will be the names of the wordlists, and the values can be lists, filenames, or a mixture of both. For example:

You can do that as follows:

```elixir
defmodule SwappyUser do
  @wordlists %{
    tiny: ["pares", "parse", "pears", "reaps", "spare", "spear"],
    tiny_spanish: ["mañana", "maña", "na", "mana", "ña"],
    foody: "test/foody_wordlist.txt"
  }

  use Swappy
end
```

You can pass the name of the wordlist to use when generating anagrams: `SwappyUser.anagrams_of("pares", :tiny)`. If no wordlist name is given, `:default` is assumed. If your map includes a `:default`, it will take the place of the one included with Swappy.

## Legal Characters

You can also customize which characters Swappy considers "legal" for the purposes of comparison. "Illegal" characters are not considered when deciding how things can be rearranged, but can still show up in your anagrams.

For instance, the default list of legal characters is just `a` through `z`, which does not include apostrophes. Therefore, Swappy would consider that "i'm" could be rearranged to spell "mi", or vice versa. If `'` were a legal character, you couldn't find anagrams of "I'm cool" unless the result also contained one apostrophe.

You can customize the list of legal characters by setting `@legal_chars` in your module to be a charlist before you `use Swappy`. For instance:

```elixir
defmodule SwappyUser do
  @legal_chars 'abcdefghijklmnopqrstuvwxyz' ++ 'áéíóúüñ'

  use Swappy
end
```

## About the Wordlist

If you want anagrams that include sports-related words, computer slang, or whatever appeals to you, you'll need to use a custom wordlist.

The wordlist you use has a huge effect on the number and quality of your anagrams, as well as the time it takes to generate them.

Some possible starting wordlists can be found at [http://norvig.com/ngrams/](http://norvig.com/ngrams/).

However, you probably want to clean up whatever you use. In particular, **every short word you supply vastly increases the number of anagrams generated**. You want as few 1-letter and 2-letter words as you can have.

Some wordlists include things 'r' as a word, on the grounds that you can say "The word 'rake' starts with 'r'." However, having every individual letter considered a "word" makes the number of possible anagrams astronomical.

See `Mix.Tasks.CleanUpEnglishDictionary` for an opinionated filter, then make your own if you wish.

## Configuration

You can control the number of processes that Swappy uses to search for anagrams by setting an variable in your environment config. You can tweak this number and try running `mix performance` to see how it changes.

```elixir
config :swappy, worker_count: 4
```

## Development

Whatever else you do, check `mix performance` to ensure that anagram generation speed does not degrade.
