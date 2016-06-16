defmodule CustomAnagramUser do

  @legal_codepoints Enum.to_list(?a..?z) ++ ["á", "é", "í", "ó", "ú", "ü", "ñ"]
  # TODO fix this along with the test
  # def legal_codepoint?(codepoint) do
  #   codepoint in @legal_codepoints
  # end

  @custom_wordlists %{
    tiny: ["pares", "parse", "pears", "reaps", "spare", "spear"],
    tiny_spanish: ["mañana", "maña", "na", "mana", "ña"]
  }
  @wordlists Map.merge(Anagram.default_wordlists, @custom_wordlists)

  use Anagram, wordlists: @wordlists
end
