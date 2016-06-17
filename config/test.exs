use Mix.Config

config :anagrams, dictionary_files: %{ default: "lib/default_wordlist.txt", }
config :anagrams, :legal_chars, 97..122 # lowercase a..z 
