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

  # Takes a filename, returns list with one string per non-empty line
  def load_file(filename) do
    filename
    |> Path.expand
    |> File.stream!
    |> Enum.map(&String.strip/1)
  end

  # Merges the user's map of wordlists with Swappy defaults and loads files as necessary
  def add_wordlists(user_wordlists) do
    wordlists = Map.merge(default_wordlists, (user_wordlists || %{}))
    for {wordlist_name, wordlist} <- wordlists, into: %{} do
      loaded_wordlist = if is_binary(wordlist) do
        load_file(wordlist)
      else
        wordlist
      end
      {wordlist_name, loaded_wordlist}
    end
  end

  defp default_wordlists do
    %{default: "#{Path.dirname(__ENV__.file)}/../default_wordlist.txt"}
  end

end
