defmodule Anagram.Dictionary do

  # Transform a map of dictionary names and filenames into one of dictionary names and lists of words
  def load_files(map) do
    for {k, v} <- map, into: %{} do
      {k, load_file(v)}
    end
  end

  # Takes a filename, returns list with one string per non-empty line
  def load_file(filename) do
    filename
    |> Path.expand
    |> File.stream!
    |> Enum.map(&String.strip/1)
  end
end
