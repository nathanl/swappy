defmodule CustomAnagramUser do

  @legal_codepoints 'abcdefghijklmnopqrstuvwxyz' ++ 'áéíóúüñ'
  @wordlists %{
    tiny: ["pares", "parse", "pears", "reaps", "spare", "spear"],
    tiny_spanish: ["mañana", "maña", "na", "mana", "ña"]
  }

  use Anagram
end
