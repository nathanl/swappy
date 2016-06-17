defmodule Mix.Tasks.GenerateAnagrams do
  use Mix.Task
  use Swappy

  @shortdoc "Simple task to generate anagrams for a phrase"
  @moduledoc """
  Uses the default dictionary. Usage:
    mix generate_anagrams "my phrase"

  If you give a second argument, it will be taken as letters to omit. Eg:
    mix generate_anagrams "my phrase" "as"

  This can be used to work toward something funny - eg, if you think the word "as" is funny, and you
  see it in your results somewhere, exclude it and run again, knowing that whatever you find, you can
  add "as" back to it. Repeat as necessary.
  """
  def run([phrase]) do
    anagrams_of(phrase) |> Enum.each(&(IO.puts(&1)))
  end

  def run([phrase, without]) do
    # TODO - detect closed pipe and stop gracefully? Eg if piping to head
    alphagrams = [phrase, without] |> Enum.map(&Swappy.Alphagram.to_alphagram/1)
    case apply(Swappy.Alphagram, :without, alphagrams) do
      {:ok, remaining_alphagram, _without} ->
        remaining_phrase = Swappy.Alphagram.to_string(remaining_alphagram)
        IO.puts ~s(phrase "#{remaining_phrase}" \("#{phrase}" without "#{without}"\) has anagrams:)
        anagrams_of(remaining_phrase) |> Enum.each(&(IO.puts(&1)))
    end
  end
end
