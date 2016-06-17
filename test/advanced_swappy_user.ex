defmodule AdvancedSwappyUser do

  @legal_codepoints 'abcdefghijklmnopqrstuvwxyz' ++ 'áéíóúüñ'
  @inline_wordlists %{
    tiny: ["pares", "parse", "pears", "reaps", "spare", "spear"],
    tiny_spanish: ["mañana", "maña", "na", "mana", "ña"],
  }
  @wordlists_from_files Swappy.Dictionary.load_files(%{
    foody: "test/foody_wordlist.txt"
  })
  @wordlists Map.merge(@inline_wordlists, @wordlists_from_files)

  use Swappy
end
