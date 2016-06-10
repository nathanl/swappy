defmodule CustomAnagramUser do
  use Anagram

  @legal_codepoints Enum.to_list(?a..?z) ++ ["á", "é", "í", "ó", "ú", "ü", "ñ"]
  def is_legal_codepoint?(codepoint) do
    codepoint in @legal_codepoints
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
