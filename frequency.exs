defmodule Frequency do
  @doc """
  Count letter frequency in parallel.

  Returns a dict of characters to frequencies.

  The number of worker processes to use can be set with 'workers'.
  """
  @spec frequency([String.t], pos_integer) :: map
  def frequency(texts, workers) when is_list(texts) and is_integer(workers) and workers > 0 do
    texts
    |> split_texts_in_chunks(workers)
    |> Stream.map(&Task.async(fn -> process_texts_chunk_async(&1) end))
    |> Stream.flat_map(&Task.await(&1))
    |> Enum.reduce(%{}, &merge_maps(&1, &2))
  end

  @doc """
  Split texts in a chunks according to a number of workers.

  Returns the list of lists each containing texts (bit strings).
  """
  @spec split_texts_in_chunks([String.t], pos_integer) :: [[String.t]]
  def split_texts_in_chunks(texts, workers) do
    texts
    |> round_robin(workers, 0, %{})
    |> Map.values()
  end

  @doc """
  Split given list into a map containing lists according to a number of workers.

  Returns map where worker index is a key and a list of texts are values.
  """
  @spec round_robin([], any, any, map) :: map
  def round_robin([], _, _, robin_maps), do: robin_maps

  @doc """
  Split given list into a map containing lists  according to a number of workers.

  Returns map where worker index is a key and a list of texts are values.
  """
  @spec round_robin([String.t], pos_integer, pos_integer, map) :: map
  def round_robin([h | t], workers, i, robin_maps) do
    upd_robin_maps = Map.update(robin_maps, i, [h], &[h | &1])
    case i + 1 do
      nxt when nxt < workers  -> round_robin(t, workers, nxt, upd_robin_maps)
      nxt when nxt == workers -> round_robin(t, workers, 0, upd_robin_maps)
    end
  end

  @doc """
  Process each chunk of input texts - list of binary strings.

  Returns list containing letter frequency maps.
  """
  @spec process_texts_chunk_async([[binary]]) :: [map]
  def process_texts_chunk_async(texts_chunk) do
    texts_chunk
    |> Stream.map(&String.downcase(&1))
    |> Stream.map(&exract_letters(&1))
    |> Stream.map(&map_letters(&1))
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
  Create a letter frequency map from single list of unicode letters

  Returns a map containing unicode letters as keys and their frequency as a values
  """
  @spec map_letters([binary]) :: map
  def map_letters(letters) when is_list(letters) do
    Enum.reduce(letters, %{}, fn(letter, acc) ->
      Map.update(acc, letter, 1, &(&1 + 1))
    end)
  end

  @doc """
  Merges two maps

  Returns a merged map containing keys and a sum of values from two given maps
  """
  @spec merge_maps(map, map) :: map
  def merge_maps(map, acc) when is_map(map) and is_map(acc) do
    Map.merge(acc, map, fn(_key, v1, v2) ->
      v1 + v2
    end)
  end
end
