defmodule ConfiguredAnagrams do
  @dictionaries (for {k, v} <- Application.get_env(:anagrams, :dictionary_files, %{}), into: %{} do
    {k, Anagrams.Dictionary.load_human_readable_dictionary(v)}
  end)
  @legal_codepoints Application.get_env(:anagrams, :legal_codepoints)

  use Anagrams
end
