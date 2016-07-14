defmodule Frequency do
  @doc """
  Count letter frequency in parallel.

  Returns a dict of characters to frequencies.

  The number of worker processes to use can be set with 'workers'.
  """
  @spec frequency([String.t], pos_integer) :: map
  def frequency(texts, workers) when is_list(texts) and is_integer(workers) and workers > 0 do
    texts
    |> Stream.map(&String.downcase(&1))
    |> Stream.map(&exract_letters(&1))
    |> Stream.chunk(workers, workers, [])
    |> Stream.flat_map(&map_letters_async(&1))
    |> Enum.reduce(%{}, &merge_maps(&1, &2))
  end

  @doc """
  Extract unicode letters from the given string.

  Returns list containing unicode letters only
  """
  @spec exract_letters(String.t) :: [binary]
  def exract_letters(text) when is_bitstring(text) do
    Regex.scan(~r/\p{L}\p{M}*+/u, text)
    |> List.flatten()
  end

  @doc """
  Create a letter frequency map from list of multiple lists of unicode letters asyncroniously

  Returns a list of maps containing unicode letters as keys and their frequency as a values
  """
  @spec map_letters_async([[binary]]) :: [map]
  def map_letters_async(lists_of_letters) when is_list(lists_of_letters) do
    lists_of_letters
    |> Enum.map(&Task.async(fn -> map_letters(&1) end))
    |> Enum.map(&Task.await(&1))
  end

  @doc """
  Create a letter frequency map from single list of unicode letters

  Returns a map containing unicode letters as keys and their frequency as a values
  """
  @spec map_letters([binary]) :: map
  def map_letters(letters) when is_list(letters) do
    Enum.reduce(letters, %{}, fn(letter, acc) -> Map.update(acc, letter, 1, &(&1 + 1)) end)
  end

  @doc """
  Merges two maps

  Returns a merged map containing keys and a sum of values from two given maps
  """
  @spec merge_maps(map, map) :: map
  def merge_maps(map, acc) when is_map(map) and is_map(acc) do
    Map.merge(acc, map, fn(_key, v1, v2) -> v1 + v2 end)
  end
end
