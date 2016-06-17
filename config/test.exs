use Mix.Config

config :anagrams, dictionary_files: %{ default: "lib/common_words_dictionary.txt", }
config :anagrams, :legal_codepoints, 97..122 # lowercase a..z 
