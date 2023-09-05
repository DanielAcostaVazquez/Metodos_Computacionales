#Daniel Francisco Acosta Vazquez - A01736279
defmodule Automatas do
  #Funcion que hace el producto cruz (usado para calcular Q a partir de q1 y q2)
  def cross(l1, l2) do
    Enum.map(l1, fn l1 ->
      Enum.map(l2, fn l2 -> {l1,l2} end)
    end)
    |> List.flatten
  end

  #Funcion para obtener el nuevo delta a partir de los delta de los dos automatas
  def delta({q1,s1,d1,_q01,_f1},{q2,_s2,d2,_q02,_f2}) do
    q = cross(q1,q2)
    Enum.map(s1, fn x ->
      Enum.map(q, fn {k,v} -> {{k,v,x},{(Map.get(d1,{k,x})),(Map.get(d2,{v,x}))}} end)
    end)
    |> List.flatten
    |> Map.new
  end

  #Funcion para obtener los estados finales desde los estados finalesde ambos automatas
  def final({q1,_s1,_d1,_q01,f1},{q2,_s2,_d2,_q02,f2}) do
    cross(f1,q2) ++ cross(q1,f2)
    |> Enum.uniq
  end

  #Funcion para realizar la union de los dos automatas
  def union({q1,s1,d1,q01,f1},{q2,_s2,d2,q02,f2}) do
    {cross(q1,q2),
    s1,
    delta({q1,s1,d1,q01,f1},{q2,1,d2,q02,f2}),
    {q01,q02},
    final({q1,s1,d1,q01,f1},{q2,1,d2,q02,f2})
    }
  end

  #Funcion para podar un automata reduciendolo a los estados, estados finales y transciciones que si se utilizan
  def prune({q,s,d,q0,f}) do
    noState = q -- traverse({q,s,d,q0,f})
    {q -- noState, s, Map.drop(d, deleteKeys(noState,s)), q0, Enum.filter(f, fn x -> x not in noState end)}
  end

  #Funcion de ayuda para obtenr las llaves a eliminar
  defp deleteKeys(l,s1) do
    Enum.map(s1, fn x ->
      Enum.map(l, fn {k,v} -> {k,v,x} end)
    end)
    |> List.flatten
  end

  #Funcion para limpiar el resultado dada por la funcion traverse
  defp traverse({_q,_s,d,q0,_f}) do
    traverse(d, q0, [])
    |> List.flatten
    |> Enum.uniq
  end

  #Funcion para visitar todos los estados posibles del automata
  defp traverse(map, q0, acc) do
    if q0 not in acc do
      Enum.filter(Map.keys(map), fn {k,v,x} -> {k,v,x} == Tuple.append(q0, x) end)
      |> Enum.map(fn {k,v,x} -> Map.get(map, {k,v,x}) end)
      |> Enum.map(fn x -> traverse(map, x, [q0|acc]) end)
    else
      acc
    end
  end
end
