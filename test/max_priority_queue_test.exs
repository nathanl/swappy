defmodule MaxPriorityQueueTest do
  use ExUnit.Case

  # I want leftmost to win - so increase numbers as we go
  # for same number in slot N, I want longer to win

  # there's no way around the fact that a longer tuple or list is greater than a shorter one.
  # therefore I need a max heap implementation.

  # https://github.com/ewildgoose/elixir_priority_queue/issues/1
  # https://github.com/nathanl/elixir_priority_queue/tree/max_hack

  test "max heap priority queue" do
    q = PriorityQueue.new
    # I think this line and the following can never be in the queue at the same time because gold is a child of poop, so which way the comparison would go is irrelevant. If we can always compare by Nth value, a min heap may be fine.
    q = PriorityQueue.put(q, {[0,-1,-1], "gold"})
    q = PriorityQueue.put(q, {[0,-1], "cake"})
    q = PriorityQueue.put(q, {[0,-2], "bread"})
    q = PriorityQueue.put(q, {[0,-3], "mush"})
    q = PriorityQueue.put(q, {[0,-4], "poop"})
    {{_p, a1}, q} = PriorityQueue.pop!(q)
    {{_p, a2}, q} = PriorityQueue.pop!(q)
    {{_p, a3}, q} = PriorityQueue.pop!(q)
    {{_p, a4}, q} = PriorityQueue.pop!(q)
    {{_p, a5}, _q} = PriorityQueue.pop!(q)
    assert [a1, a2, a3, a4, a5] == ["gold", "cake", "bread", "mush", "poop"]
  end

end
