defmodule Mix.Tasks.GenerateAnagrams do
  use Mix.Task
  use Swappy

  @shortdoc "Simple task to generate anagrams for a phrase"
  @moduledoc """
  Uses the default dictionary. Usage:
    mix generate_anagrams "hoverboard fever"

  If you give a second argument, it will be taken as a limit for the number of anagrams to generate. Eg:
    mix generate_anagrams "hoverboard fever" 10

  If the limit isn't a valid number, it will be treated as "infinity". Eg:
    mix generate_anagrams "hoverboard fever" infinity

  If you give a third argument, it will be treated as words the anagram must include. Eg:
    mix generate_anagrams "hoverboard fever" 10 "rob drove"

  This can be used to work toward something funny - if you see a word or words
  you like, start requiring them, run again, and repeat.
  """

  # TODO - detect closed pipe and stop gracefully? Eg if piping to head
  def run([phrase]) do
    anagrams_of(phrase) |> Enum.each(&(IO.puts(&1)))
  end

  def run([phrase, limit]) do
    anagrams_of(phrase, %{limit: parse_int(limit)}) |> Enum.each(&(IO.puts(&1)))
  end

  def run([phrase, limit, without]) do
    alphagrams = [phrase, without] |> Enum.map(&Swappy.Alphagram.to_alphagram/1)
    case apply(Swappy.Alphagram, :without, alphagrams) do
      {:ok, remaining_alphagram, _without} ->
        remaining_phrase = Swappy.Alphagram.to_string(remaining_alphagram)
        anagrams_of(remaining_phrase, %{limit: parse_int(limit)}) |> Enum.each(fn (anagram_without) ->
          IO.puts [without, " ", anagram_without]
        end)
    end
  end

  defp parse_int(limit) when is_binary(limit) do
    case Integer.parse(limit) do
      :error -> :infinity
      {val, _} -> val
    end
  end

  defp parse_int(_limit), do: :infinity
end
