defmodule Swappy.Timey do
  @micros_per_second 1_000_000.0

  def micros do
    {_, secs, micros} = :os.timestamp
    (secs * @micros_per_second) + micros
  end

  def format(microseconds) do
    seconds = microseconds / @micros_per_second
    "#{seconds}s"
  end
end
