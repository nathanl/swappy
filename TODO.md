- Mo documentation
- Doctests?
- Implement "stop after finding N anagrams"
- PROPERTY TESTS!?!?!
- crazy idea: sigil for alphagrams, which ensures sorted charlist

## Use a Max Priority Queue to store and assign jobs

See https://github.com/ewildgoose/elixir_priority_queue/issues/1

- First, build a dictionary struct. One property will be the current alphagram -> wordlist map, but a new one will be an ordered list of alphagrams. If we have a wordlist of "bat", "hat", "tab", 'abt' should be item 0, 'aht', 1, and when we see "tab", we ignore because we already found 'abt'. We'll then use that list to start off with instead of Map.keys(dictionary).

NOTE - instead of tuples, use lists?

Each job would get a priority as follows: the first job is `{0}`. Its children are `{0,0}, {0,-1}, {0,-2}...`. Children of `{0,-1}` are `{0,-1,0}, {0,-1,-1}...`.

Because Elixir compares tuples first by length (longer is greater), then by value (a tuple starting with `2` is greater than one starting with `1`), this scheme should mean that we prioritize deeper searches over shallower ones, always pursuing complete anagrams over ones that still need lots of processing. (Although, hmmm, if it's possible to get something in two recursions on one branch, we'd want to do that before pursuing something that requires 10 recursions...)

Doing this allows several advantages.
  - Building the "most interesting" anagrams first, as defined by the user-ordered input dictionary. Eg, maybe user wants political anagrams, or poo-based ones, or ones with the longest words.
  - Working those words down to complete anagrams before moving on to expand lower-priority, incomplete ones will shorten the time to useful results, especially helpful if we're stopping when we finish N anagrams.

## Priorities

{0} vs {0,0} is impossible because {0} produces {0,0}
{0,0} vs {0,0,1} is impossible for the same reason
{0,0} vs {0,1} - {0,0} wins by priority
{0,0} vs {1,0} - {0,0} wins by priority
{0,0} vs {1,0,0} - {0,0} wins by priority

So all we have to do is compare on each number, and the first time one is lower, it wins.
