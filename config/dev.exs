use Mix.Config

config :anagrams, dictionary_files: %{ default: "/Users/nathanl/code/anagram/tmp/sil_wordlist.txt", }
config :anagrams, :legal_codepoints, 97..122 # lowercase a..z 
