# Daniel Francisco Acosta Vazquez - A01736279
# Actividad 3.1: Programando la unión de dos autómatas finitos deterministas

defmodule Automatas2 do

  defp transition(q, s, d) do
    case Enum.filter(d, fn {src, sy, _t} -> src == q and sy == s end) do

      [] -> []

      [{_src, _sy, t}] -> [t]

      res -> Enum.reduce(res, [], fn {_src, _sy, t}, acc -> [t|acc] end)

    end
  end

  defp cross(k, j) do
    Enum.map(k, fn x -> Enum.map(j, fn y -> {x,y} end) end)
    |> List.flatten()
  end

  def power([]) do
    [[]]
  end

  def power([a|s]) do
    powers = power(s)
    Enum.map(powers, fn sm -> [a|sm] end) ++ powers
  end

  def determinize({states, symbs, delta, q, f}) do
    statesp = power(states)|> Enum.sort_by(&length/1)

    deltap = Enum.map(cross(statesp, symbs), fn {set, sym} -> {set, sym, Enum.flat_map(set, fn val -> transition(val, sym, delta) end)} end) # Enum.map( fn e -> List.to_tuple(e) end) |>

    {
      statesp,
      symbs,
      deltap,
      [q],
      Enum.filter(statesp, fn val -> MapSet.intersection(MapSet.new(val),MapSet.new(f)) != MapSet.new([]) end)
    }

  end

  defp traverse(d, q, acc) do

    case Enum.filter(d, fn {src, _sy, _t} -> src == q end) do
      [] -> acc

      h ->
        Enum.reduce(h, acc, fn {src, sy, t}, acc ->
        if {src, sy, t} not in acc do
          traverse(d, t, [{src, sy, t}|acc])
        else
          acc
          end
        end)
    end

  end

  def prune({q, sy, d, q0, f}) do
    dN = (traverse(d |> Enum.filter(fn {_src, _sym, t} -> t !== [] end), q0, []) |> Enum.reverse())
    dL = Enum.reduce(dN, [], fn {src, sym, t}, acc -> [src, sym, t|acc] end)

    qN = Enum.filter(q, fn v -> v in dL end)

    fN = Enum.filter(f, fn v -> v in dL end)

    {qN,
    sy,
    dN,
    q0,
    fN
    }
  end

  def to_dot({_q, _sy, d, _q0, _f}) do
    cadena = (d
      |> Enum.map(fn {m1, t, m2} -> "\"{#{Enum.join(m1,",")}}\" -> \"{#{Enum.join(m2,",")}}\" [label=\"#{t}\"];" end) |> Enum.join("\n"))
      "digraph G {\n#{cadena}\n}\n\n"
      |> IO.puts
  end

  defp traverseE(d, q, acc) do
    case Enum.filter(d, fn {src, sy, _t} -> (src == q and sy == '') end) do
      [] -> acc

      h ->
        Enum.reduce(h, acc, fn {_src, _sy, t}, acc ->
        if t not in acc do
          traverseE(d, t, [t|acc])
        else
          acc
          end
        end)
    end
  end

  def e_closure({_q, _symbs, d, _q0, _f}, states) do
    Enum.flat_map(states, fn x -> traverseE(d, x, [x]) |> Enum.reverse end)
    |> Enum.sort
    |> Enum.uniq
  end

  def e_determinize({states, sy, d, q, f}) do
    statesP = power(states)|> Enum.sort_by(&length/1)
    syNoE = List.delete(sy,'')

    dP = Enum.map(cross(statesP, syNoE), fn {set, sym} -> {set, sym, Enum.flat_map(set, fn val -> e_closure({states, sy, d, q, f},transition(val, sym, d)) end)} end)
    to_dot(prune({
      statesP,
      sy,
      dP,
      e_closure({states, sy, d, q, f},[q]),
      Enum.filter(statesP, fn val -> MapSet.intersection(MapSet.new(val),MapSet.new(f)) != MapSet.new([]) end)
    }))

  end

end
