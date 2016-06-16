defmodule CustomAnagramUser do

  @legal_codepoints ("abcdefghijklmnopqrstuvwxyz" |> String.codepoints) ++ ["á", "é", "í", "ó", "ú", "ü", "ñ"]
  @wordlists %{
    tiny: ["pares", "parse", "pears", "reaps", "spare", "spear"],
    tiny_spanish: ["mañana", "maña", "na", "mana", "ña"]
  }

  use Anagram
end
