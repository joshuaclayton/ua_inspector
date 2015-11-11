defmodule UaInspector.Parser.Client do
  @moduledoc """
  UaInspector client information parser.
  """

  use UaInspector.Parser

  alias UaInspector.Database.Clients
  alias UaInspector.Parser.BrowserEngine
  alias UaInspector.Result
  alias UaInspector.Util

  def parse(ua), do: parse(ua, Clients.list)


  defp parse(_,  []),                             do: :unknown
  defp parse(ua, [{ _index, entry } | database ]) do
    if Regex.match?(entry.regex, ua) do
      parse_data(ua, entry)
    else
      parse(ua, database)
    end
  end


  defp parse_data(ua, entry) do
    name    = resolve_name(ua, entry)
    version = resolve_version(ua, entry)
    engine  = maybe_resolve_engine(entry.type, entry.engine, ua, version)

    %Result.Client{
      engine:  engine,
      name:    name,
      type:    entry.type,
      version: version
    }
  end


  defp maybe_resolve_engine("browser", engine_data, ua, version) do
    engine = case resolve_engine(engine_data, version) do
      ""     -> BrowserEngine.parse(ua)
      engine -> engine
    end

    engine |> Util.maybe_unknown()
  end

  defp maybe_resolve_engine(_, _, _, _), do: :unknown


  defp resolve_engine(nil, _),                      do: ""
  defp resolve_engine([{ "default", "" }], _),      do: ""
  defp resolve_engine([{ "default", default }], _), do: default

  defp resolve_engine([{ "default", default } | non_default ], version) do
    [{ "versions", engines }] = non_default

    version  = version |> to_string() |> Util.to_semver()
    filtered = Enum.filter engines, fn ({ maybe_version, _ }) ->
      maybe_version = maybe_version |> to_string() |> Util.to_semver()

      :lt != Version.compare(version, maybe_version)
    end

    case List.last(filtered) do
      nil           -> default
      { _, ""     } -> ""
      { _, engine } -> engine
    end
  end

  defp resolve_name(ua, entry) do
    captures = Regex.run(entry.regex, ua)

    (entry.name || "")
      |> Util.uncapture(captures)
      |> Util.sanitize_name()
      |> Util.maybe_unknown()
  end

  defp resolve_version(ua, entry) do
    captures = Regex.run(entry.regex, ua)

    (entry.version || "")
    |> Util.uncapture(captures)
    |> Util.sanitize_version()
    |> Util.maybe_unknown()
  end
end
