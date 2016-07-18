if !System.get_env("EXERCISM_TEST_EXAMPLES") do
  Code.load_file("frequency.exs")
end

ExUnit.start
ExUnit.configure exclude: :pending, trace: true

# Your code should contain a frequency(texts, workers) function which accepts a
# list of texts and the number of workers to use in parallel.

defmodule FrequencyTest do
  use ExUnit.Case

  # Poem by Friedrich Schiller. The corresponding music is the European Anthem.
  @ode_an_die_freude """
  Freude schöner Götterfunken
  Tochter aus Elysium,
  Wir betreten feuertrunken,
  Himmlische, dein Heiligtum!
  Deine Zauber binden wieder
  Was die Mode streng geteilt;
  Alle Menschen werden Brüder,
  Wo dein sanfter Flügel weilt.
  """

  # Dutch national anthem
  @wilhelmus """
  Wilhelmus van Nassouwe
  ben ik, van Duitsen bloed,
  den vaderland getrouwe
  blijf ik tot in den dood.
  Een Prinse van Oranje
  ben ik, vrij, onverveerd,
  den Koning van Hispanje
  heb ik altijd geëerd.
  """

  # American national anthem
  @star_spangled_banner """
  O say can you see by the dawn's early light,
  What so proudly we hailed at the twilight's last gleaming,
  Whose broad stripes and bright stars through the perilous fight,
  O'er the ramparts we watched, were so gallantly streaming?
  And the rockets' red glare, the bombs bursting in air,
  Gave proof through the night that our flag was still there;
  O say does that star-spangled banner yet wave,
  O'er the land of the free and the home of the brave?
  """

  # Returns the frequencies in a sorted list. This means it doesn't matter if
  # your frequency() function returns a list of pairs or some dictionary, the
  # testing code will handle it.
  defp freq(texts, workers \\ 4) do
    Frequency.frequency(texts, workers) |> Enum.sort() |> Enum.into(%{})
  end

  test "divide list of values using round robin approach - returns map" do
    assert(Frequency.round_robin([1, 2, 3, 4, 5], 1, 0, %{}) == %{0 => [5, 4, 3, 2, 1]})
    assert(Frequency.round_robin([1, 2, 3, 4, 5], 2, 0, %{}) == %{0 => [5, 3, 1], 1 => [4, 2]})
    assert(Frequency.round_robin([1, 2, 3, 4, 5], 3, 0, %{}) == %{0 => [4, 1], 1 => [5, 2], 2 => [3]})
    assert(Frequency.round_robin([1, 2, 3, 4, 5], 4, 0, %{}) == %{0 => [5, 1], 1 => [2], 2 => [3], 3 => [4]})
    assert(Frequency.round_robin([1, 2, 3, 4, 5], 5, 0, %{}) == %{0 => [1], 1 => [2], 2 => [3], 3 => [4], 4 => [5]})
    assert(Frequency.round_robin([1, 2, 3, 4, 5], 6, 0, %{}) == %{0 => [1], 1 => [2], 2 => [3], 3 => [4], 4 => [5]})
  end

  test "divide text into chunks (lists of texts) according to a number of workers" do
    assert(Frequency.split_texts_in_chunks(["a", "bb", "ccc", "dddd"], 3) == [["dddd", "a"], ["bb"], ["ccc"]])
  end

  #@tag :pending
  test "extract unicode letters from text string into list" do
    res = Frequency.exract_letters("ab12 -c ![ü]  ?ö")
    assert(res == ["a", "b", "c", "ü", "ö"])
  end

  #@tag :pending
  test "create letters frequency map from list of unicode letters" do
    res = Frequency.map_letters(["a", "b", "c", "a", "ü", "ü", "ö", "c", "a"])
    assert(res == %{"a" => 3, "b" => 1, "c" => 2, "ö" => 1, "ü" => 2})
  end

  #@tag :pending
  test "merging two maps" do
    res = Frequency.merge_maps(%{"a" => 1, "b" => 2, "c" => 3}, %{"b" => 4, "c" => 5, "d" => 6})
    assert(res == %{"a" => 1, "b" => 6, "c" => 8, "d" => 6})
  end

  #@tag :pending
  test "proces list (chunk) of texts" do
    res =
      Frequency.process_texts_chunk_async(["abacab", "üüö", "ъ"])
      |> Enum.to_list()

    assert(res == [%{"a" => 3, "b" => 2, "c" => 1}, %{"ü" => 2, "ö" => 1}, %{"ъ" => 1}])
  end

  #@tag :pending
  test "no texts mean no letters" do
    assert freq([]) == %{}
  end

  #@tag :pending
  test "one letter" do
    assert freq(["a"]) == %{"a" => 1}
  end

  #@tag :pending
  test "case insensitivity" do
    assert freq(["aA"]) == %{"a" => 2}
  end

  #@tag :pending
  test "many empty texts still mean no letters" do
    assert freq(List.duplicate("  ", 10000)) == %{}
  end

  #@tag :pending
  test "many times the same text gives a predictable result" do
    assert freq(List.duplicate("abc", 1000))
         == %{"a" => 1000, "b" => 1000, "c" => 1000}
  end

  #@tag :pending
  test "punctuation doesn't count" do
    assert freq([@ode_an_die_freude])[","] == nil
  end

  #@tag :pending
  test "numbers don't count" do
    assert freq(["Testing, 1, 2, 3"])["1"] == nil
  end

  #@tag :pending
  test "all three anthems, together, 1 worker" do
    freqs = freq([@ode_an_die_freude, @wilhelmus, @star_spangled_banner], 1)
    assert freqs["a"] == 49
    assert freqs["t"] == 56
    assert freqs["ü"] == 2
  end

  #@tag :pending
  test "all three anthems, together, 4 workers" do
    freqs = freq([@ode_an_die_freude, @wilhelmus, @star_spangled_banner], 4)
    assert freqs["a"] == 49
    assert freqs["t"] == 56
    assert freqs["ü"] == 2
  end
end
