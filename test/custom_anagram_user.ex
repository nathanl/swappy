defmodule CustomAnagramUser do
  use Anagram

  @legal_codepoints Enum.to_list(Anagram.Alphagram.legal_codepoints) ++ ["á", "é", "í", "ó", "ú", "ü", "ñ"]
  def legal_codepoints do
    @legal_codepoints
  end

  @custom_wordlists %{
    tiny: ["pares", "parse", "pears", "reaps", "spare", "spear"],
    tiny_spanish: ["mañana", "maña", "na", "mana", "ña"]
  }
  @wordlists Map.merge(Anagram.default_wordlists, @custom_wordlists)
  def wordlists do
    @wordlists
  end
end
