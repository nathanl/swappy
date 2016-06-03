defmodule Anagram.Dictionary do

  # Takes a filename, returns list with one string per non-empty line
  def load_human_readable_dictionary(filename) do
    File.stream!(filename)
    |> Enum.map(&String.strip/1)
    # Throw out a bunch of tiny garbage "words" which vastly increase the
    # number of anagrams if included
    |> Enum.filter(fn (word) ->
      cond do
        String.length(word) < 2 && !word in ~w(a i o) -> false
        String.length(word) == 2 && (!word in ~w(ad ah ai am an as at aw ax ay be bi by do eh er ex go ha he hi ho id if in is it la lo ma me my of oh on or ow ox oy pa pH pi qi re so to um up us we ye yo)) -> false
        true -> true
      end
    end)
  end
  
end
