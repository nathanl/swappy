defmodule AdvancedSwappyUser do
  @legal_chars 'abcdefghijklmnopqrstuvwxyz' ++ 'áéíóúüñ'
  @wordlists %{
    tiny: ["pares", "parse", "pears", "reaps", "spare", "spear"],
    tiny_spanish: ["mañana", "maña", "na", "mana", "ña"],
    foody: "test/foody_wordlist.txt"
  }

  use Swappy
end
