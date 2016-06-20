defmodule SwappyTest do
  Code.load_file("basic_swappy_user.ex", "test")
  Code.load_file("advanced_swappy_user.ex", "test")
  use ExUnit.Case
  doctest Swappy

  test "can find the only possible anagrams using a tiny dictionary" do
    result = BasicSwappyUser.anagrams_of("onto", %{wordlist: ["on", "to"]})
    assert result == ["to on"]
  end

  test "ignores punctuation, capitalization and spaces" do
    result = BasicSwappyUser.anagrams_of("On, To!", %{wordlist: ["on", "to"]})
    assert result == ["to on"]
  end

  test "can find human-readable anagrams of a phrase using a dictionary" do
    result = BasicSwappyUser.anagrams_of("racecar", %{wordlist: ["arc", "are", "car", "care", "race"]})
    assert result == ["car race", "car care", "arc race", "arc care"]
  end

  test "can handle duplicate words in the input phrase" do
    result = BasicSwappyUser.anagrams_of("apple racecar apple", %{wordlist: ["race", "car", "apple", "racecar"]})
    assert result == ["apple racecar apple", "apple race apple car"]
  end

  test "can find words with apostrophes, like 'I'm'" do
    result = BasicSwappyUser.anagrams_of("I'm cool", %{wordlist: ["I'm", "cool", "mi"]})
    assert result == ["mi cool", "I'm cool"]
  end

  test "uses the built-in default dictionary if none is specified" do
    assert BasicSwappyUser.anagrams_of("onto") == BasicSwappyUser.anagrams_of("onto", %{wordlist: :default})
  end

  test "can find anagrams using the built-in default dictionary" do
    result = BasicSwappyUser.anagrams_of("onto")
    assert result == ["to no", "to on", "o ton", "o not", "onto"]
  end

  test "can find anagrams using a dictionary defined in the user's module or the default" do
    result = AdvancedSwappyUser.anagrams_of("spear", %{wordlist: :tiny})
    assert result == ["spear", "spare", "reaps", "pears", "parse", "pares"]
    result = AdvancedSwappyUser.anagrams_of("food", %{wordlist: :foody})
    assert result == ["of do", "doof", "food"]
    result = AdvancedSwappyUser.anagrams_of("onto")
    assert result == ["to no", "to on", "o ton", "o not", "onto"]
  end

  test "uses legal_chars as defined in the user's module" do
    result = AdvancedSwappyUser.anagrams_of("mañana", %{wordlist: :tiny_spanish})
    assert result == ["ña mana", "na maña", "mañana"]
    another_result = AdvancedSwappyUser.anagrams_of("maana", %{wordlist: :tiny_spanish})
    assert another_result != result
    assert another_result == []
  end

  test "human_readable builds a 'cartesian join' of words the alphagrams can spell" do
    anagram = [["a","c","e","r"], ["a","c","r"]]
    dictionary = %{
      ["a", "c", "e", "r"] => ["race", "care"],
      ["a", "c", "r"] => ["car"],
    }
    assert((Swappy.human_readable(anagram, dictionary) |> Enum.sort) == [
      "car care", "car race"
    ])
  end

  def ag(str), do: Swappy.Alphagram.to_alphagram(str)
  def ags(list), do: Enum.map(list, &ag/1)

  test "create_jobs makes jobs for the next level of the search tree" do
    bag = ag("onto")
    possible_words   = ags(["hi", "to", "on", "not"])
    found  = ags([])
    assert Swappy.create_jobs(bag, possible_words, found) == [
      [ found: ags(["to"]), bag: ag("on"),  possible_words: ags(["to"])],
      [ found: ags(["on" ]), bag: ag("to"), possible_words: ags(["on", "to"])],
      [ found: ags(["not" ]), bag: ag("o"), possible_words: ags(["not", "on", "to"])],
    ]
  end

  test "create_jobs adds to the list of found words" do
    bag = ag("onto")
    possible_words   = ags(["hi", "to", "on", "not"])
    found  = ags(["boat"])
    assert Swappy.create_jobs(bag, possible_words, found)  == [
      [ found: ags(["to", "boat"]), bag: ag("on"),  possible_words: ags(["to"])],
      [ found: ags(["on" , "boat"]), bag: ag("to"), possible_words: ags(["on", "to"])],
      [ found: ags(["not" , "boat"]), bag: ag("o"), possible_words: ags(["not", "on", "to"])],
    ]
  end

  test "can stop early if given a limit" do
    phrase = "a longish phrase here, no matter what"
    results = BasicSwappyUser.anagrams_of(phrase, %{limit: 1})
    assert length(results) == 1
  end

  test "assumes default dictionary even if other options given" do
    phrase = "onto"
    assert BasicSwappyUser.anagrams_of(phrase, %{limit: 1}) == BasicSwappyUser.anagrams_of(phrase, %{wordlist: :default, limit: 1})
  end

end
