defmodule Anagram.Dictionary do

  # Takes a filename, returns list with one string per non-empty line
  def load_human_readable_dictionary(filename) do
    filename
    |> Path.expand
    |> File.stream!
    |> Enum.map(&String.strip/1)
  end
end
