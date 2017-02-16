defmodule MyList do
  def uniq(list) do
    uniq(list, HashSet.new)
  end
  defp uniq([head | rest], found) do
    cond do
      HashSet.member?(found, head) -> uniq(rest, found)
      true -> [head | uniq(rest, HashSet.put(found, head))]
    end
  end
  defp uniq [], _ do
    []
  end
end

defmodule Enums do
  def my_map list, funk do
    my_map([], list, funk)
  end
  defp my_map past, [], _ do
    past
  end
  defp my_map past, [head | rest], funk do
    my_map(past ++ [funk.(head)], rest, funk)
  end

  def my_reduce list, funk do
    my_reduce list, 0, funk
  end
  defp my_reduce [], acc, _ do
    acc
  end
  defp my_reduce [h | t], acc, funk do
    my_reduce(t, funk.(h, acc), funk)
  end

  # def substrings(string) when byte_size(string) == 0 do
  #   [""]
  # end
  # def substrings string do
  #   length = String.length string
  #   walk_up(string, 0, length) ++ catch_up(string, 0, length)
  # end
  # defp walk_up(string, idx, len) when idx < len do
  #   [String.slice(string, 0, idx)] ++ walk_up(string, idx + 1, len)
  # end
  # defp walk_up(_, _, _) do
  #   []
  # end
  # defp catch_up(string, idx, len) when idx < len do
  #   [String.slice(string, idx, len)] ++ catch_up(string, idx + 1, len)
  # end
  # defp catch_up(_, _, _) do
  #   []
  # end

  # WITH TAIL CALL RECURSION
  def substrings(string) when byte_size(string) == 0 do
    [""]
  end
  def substrings string do
    length = String.length string
    walk_up(string, 0, length, []) ++ catch_up(string, 0, length, [])
  end
  defp walk_up(string, idx, len, list) when idx < len do
    walk_up(string, idx + 1, len, [String.slice(string, 0, idx)] ++ list)
  end
  defp walk_up(_, _, _, list) do
    list
  end
  defp catch_up(string, idx, len, list) when idx < len do
    catch_up(string, idx + 1, len, [String.slice(string, idx, len)] ++ list)
  end
  defp catch_up(_, _, _, list) do
    list
  end
end

IO.inspect MyList.uniq [1,2,3,1,2,3] #=> [1,2,3]
IO.inspect Enums.my_map [1,2,3,4], fn el -> el * 3 end #=> [3, 6, 9, 12]
IO.puts Enums.my_reduce [1,2,3,4], fn el, acc -> el + acc end #=> 10
IO.inspect Enums.substrings "test"