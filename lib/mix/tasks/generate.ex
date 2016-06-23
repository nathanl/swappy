defmodule Mix.Tasks.GenerateAnagrams do
  use Mix.Task
  use Swappy

  @shortdoc "Simple task to generate anagrams for a phrase"
  @moduledoc """
  Generates anagrams using the default dictionary and outputs to STDOUT. Usage:

      mix generate_anagrams input_phrase [limit] [required_words]

  ## Simple

      mix generate_anagrams "hoverboard fever"

  ## With Limit

  If you give a second argument, it will be taken as a limit for the number of anagrams to generate. Eg:

      mix generate_anagrams "hoverboard fever" 10

  If the limit can't be interpreted as an integer, it will be ignored. Eg:

      mix generate_anagrams "hoverboard fever" infinity
  
  ## With Required Words

  If you give a third argument, it will be treated as words the anagram must include. Eg:
  
      mix generate_anagrams "hoverboard fever" infinity "rob drove"

  This can be used to work toward something funny - if you see a word or words
  you like, start requiring them, run again, and repeat.
  """

  def run([phrase]) do
    print_warning "No limit given - using #{default_limit}. Use 'infinity' to find all anagrams"
    anagrams_of(phrase, %{limit: default_limit}) |> Enum.each(&(puts_unless_pipe_closed(&1)))
  end

  def run([phrase, limit]) do
    anagrams_of(phrase, %{limit: parse_int(limit)}) |> Enum.each(&(puts_unless_pipe_closed(&1)))
  end

  def run([phrase, limit, without]) do
    alphagrams = [phrase, without] |> Enum.map(&Swappy.Alphagram.to_alphagram/1)
    case apply(Swappy.Alphagram, :without, alphagrams) do
      {:ok, remaining_alphagram, _without} ->
        remaining_phrase = Swappy.Alphagram.to_string(remaining_alphagram)
        anagrams_of(remaining_phrase, %{limit: parse_int(limit)}) |> Enum.each(fn (anagram_without) ->
          puts_unless_pipe_closed [without, " ", anagram_without]
        end)
    end
  end

  # For example, if user is piping STDOUT to `head -10`
  defp puts_unless_pipe_closed(data) do
    try do
      IO.puts(data)
    rescue
      ErlangError -> exit(:shutdown)
    end
  end

  defp parse_int(limit) when is_binary(limit) do
    case Integer.parse(limit) do
      :error ->
        print_warning "'#{limit}' is not a valid limit; ignoring"
        :infinity
      {val, _} -> val
    end
  end

  defp parse_int(_limit), do: :infinity

  defp default_limit, do: 100

  defp print_warning(message) do
    IO.puts :stderr, "WARNING: #{message}"
  end
end
