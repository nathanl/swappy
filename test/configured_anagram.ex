defmodule ConfiguredAnagram do
  use Anagram
  @dictionaries Anagram.Dictionary.load_files(Application.get_env(:anagrams, :dictionary_files))
  @legal_codepoints Application.get_env(:anagrams, :legal_codepoints)

  def legal_codepoints do
    @legal_codepoints
  end

  def dictionaries do
    @dictionaries
  end

end
