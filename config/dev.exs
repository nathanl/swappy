use Mix.Config

config :anagrams, dictionary_files: %{ default: "~/code/anagram_wordlists/pruned_wordlist_by_length.txt", }
config :anagrams, :legal_chars, 97..122 # lowercase a..z 
