defmodule Swappy.Dictionary do

  defstruct alphagram_map: %{}, ordered_alphagrams: []

  def to_dictionary(wordlist) do
    to_dictionary(wordlist, Swappy.Alphagram.default_legal_chars)
  end

  # Builds a struct with two properties:
  # alphagram_map: map with entries like ['dgo'] => ["god", "dog"]
  # ordered_alphagrams: list of alphagrams in order they were first found in wordlist
  def to_dictionary(wordlist, legal_chars) do
    {alphagram_map, alphagram_list} = Enum.reduce(wordlist, {%{}, []}, fn word, {ag_map, ordered_ags} ->
      word = String.strip(word)
      if word == "" do
        {ag_map, ordered_ags}
      else
        alphagram = Swappy.Alphagram.to_alphagram(word, legal_chars)
        {updated_map, updated_list} = if Map.has_key?(ag_map, alphagram) do
          existing_words_for_alphagram = Map.get(ag_map, alphagram)
          updated_map = Map.put(ag_map, alphagram, [word|existing_words_for_alphagram])
          {updated_map, ordered_ags}
        else
          updated_list = [alphagram|ordered_ags]
          {Map.put(ag_map, alphagram, [word]), updated_list}
        end
      end
    end)
    %__MODULE__{alphagram_map: alphagram_map, ordered_alphagrams: (:lists.reverse(alphagram_list))}
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
