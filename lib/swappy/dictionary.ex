defmodule Swappy.Dictionary do

  def to_dictionary(wordlist) do
    to_dictionary(wordlist, Swappy.Alphagram.default_legal_chars)
  end

  # returns map with entries like ["d", "g", "o"] => ["god", "dog"]
  def to_dictionary(wordlist, legal_chars) do
    Enum.reduce(wordlist, %{}, fn word, map_acc ->
      word = String.strip(word)
      if word == "" do
        map_acc
      else
        # If key isn't found, the value passed to our function is 'nil'
        update_in(map_acc, [Swappy.Alphagram.to_alphagram(word, legal_chars)], &([word|(&1 || [])]))
      end
    end)
  end

  # Transform a map of dictionary names and filenames into one of dictionary names and lists of words
  def load_files(map) do
    for {k, v} <- map, into: %{} do
      {k, load_file(v)}
    end
  end

  # Takes a filename, returns list with one string per non-empty line
  def load_file(filename) do
    filename
    |> Path.expand
    |> File.stream!
    |> Enum.map(&String.strip/1)
  end
end
