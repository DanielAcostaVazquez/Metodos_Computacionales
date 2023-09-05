defmodule Exp do
  def exec(str) do
    str
    |> to_charlist()
    |> :scanner.string()
    |> elem(1)
    |> Enum.map(fn {token, cl} ->
      case token do
        :integer -> "<code style=\"color:blue\">#{to_string(cl)}</code>"
        :id -> "<code style=\"color:magenta\">#{to_string(cl)}</code>"
        _ -> to_string(cl)
      end
    end)
  end
end
