defmodule Mix.Tasks.CleanUpEnglishDictionary do
  use Mix.Task

  @shortdoc "Opinionated filter for English dictionaries"
  @moduledoc """
  Opinionated filter for English dictionaries - removes 'useless' short (1-2 character) words for performance.
  Which short words are useful is a matter of opinion - eg, I decided that 'mb' was useful but 'co' wasn't.
  In any case, anagrams are found by repeatedly subtracting valid words, so the more very short words we have, the more times we must recurse, and the longer it takes us. The difference can be dramatic, so it's definitely worth filtering your dictionary somehow, even if you don't use this exact filter.
  """
  # This is the opinionated part.
  @valid_short_words ~w[a i o ab ad ah am an as at aw ax be by do eh ex go ha hi ho ie if in is it ma me mr ms my no of oh ok on or ow ox pa pi so to tv uh um up us vs we ye yo]

  def run([input_file_path, output_file_path]) do
    output =
      input_file_path
      |> Path.expand()
      |> File.stream!()
      |> Enum.map(&String.trim/1)
      |> Enum.filter(&valid_word?/1)

    # Add line breaks
    output = output |> Enum.map(fn result -> [result, "\n"] end)

    output_file_path
    |> Path.expand()
    |> File.write!(output)
  end

  defp valid_word?(word) do
    cond do
      String.length(word) > 2 -> true
      word in @valid_short_words -> true
      true -> false
    end
  end
end
