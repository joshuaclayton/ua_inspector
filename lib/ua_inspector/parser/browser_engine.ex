defmodule UaInspector.Parser.BrowserEngine do
  @moduledoc """
  UaInspector browser engine information parser.
  """

  use UaInspector.Parser

  alias UaInspector.Database.BrowserEngines

  def parse(ua), do: parse(ua, BrowserEngines.list)


  defp parse(_,  []),                             do: :unknown
  defp parse(ua, [{ _index, entry } | database ]) do
    if Regex.match?(entry.regex, ua) do
      entry.name
    else
      parse(ua, database)
    end
  end
end
