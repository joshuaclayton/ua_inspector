defmodule UaInspector.Parser do
  @moduledoc """
  Parser module to call individual data parsers and aggregate the results.
  """

  alias UaInspector.Parser
  alias UaInspector.Result
  alias UaInspector.ShortCodeMap
  alias UaInspector.Util

  defmacro __using__(_opts) do
    quote do
      @behaviour unquote(__MODULE__)
    end
  end

  @doc """
  Parses information from a user agent.

  Returns `:unknown` if no information is not found in the database.

      iex> parse("--- undetectable ---")
      :unknown
  """
  @callback parse(ua :: String.t) :: atom | map


  @doc """
  Checks if a user agent is a known bot.
  """
  @spec bot?(String.t) :: boolean
  def bot?(ua) do
    :unknown != Parser.Bot.parse(ua)
  end

  @doc """
  Parses a given user agent string.
  """
  @spec parse(String.t) :: map
  def parse(ua) do
    case Parser.Bot.parse(ua) do
      :unknown -> parse_client(ua)
      bot      -> bot
    end
  end

  @doc """
  Parses a user agent without checking for bots.
  """
  @spec parse_client(String.t) :: map
  def parse_client(ua) do
    ua
    |> assemble_result()
    |> maybe_fix_android()
    |> maybe_fix_opera_tv_store()
    |> maybe_fix_windows()
    |> maybe_detect_desktop()
  end


  defp assemble_result(ua) do
    %Result{
      user_agent: ua,
      client:     Parser.Client.parse(ua),
      device:     Parser.Device.parse(ua),
      os:         Parser.OS.parse(ua)
    }
  end


  defp maybe_detect_desktop(%{ os: :unknown } = result), do: result

  defp maybe_detect_desktop(%{ device: %{ type: :unknown }} = result) do
    case Util.OS.desktop_only?(result.os.name) do
      true  -> %{ result | device: %{ result.device | type: "desktop" }}
      false -> result
    end
  end

  defp maybe_detect_desktop(result), do: result


  # Android <  2.0.0 is always a smartphone
  # Android == 3.*   is always a tablet
  # treat Android feature phones as smartphones
  defp maybe_fix_android(%{ os: %{ version: :unknown }} = result) do
    result
  end

  defp maybe_fix_android(%{ os:     %{ name: os_name },
                            device: %{ type: "feature phone" }} = result) do
    short_code = os_name |> ShortCodeMap.OSs.to_short()
    family     = short_code |> Util.OS.family()

    case family do
      "Android" -> %{ result | device: %{ result.device | type: "smartphone" }}
      _         -> result
    end
  end

  defp maybe_fix_android(%{ os:     %{ name: "Android" } = os,
                            device: %{ type: :unknown }} = result) do
    version = Util.to_semver(os.version)
    type    =  cond do
      smartphone_android?(version) -> "smartphone"
      tablet_android?(version)     -> "tablet"
      true                         -> result.device.type
    end

    %{ result | device: %{ result.device | type: type }}
  end

  defp maybe_fix_android(result), do: result


  defp smartphone_android?(version) do
    :lt == Version.compare(version, "2.0.0")
  end

  defp tablet_android?(version) do
    :lt != Version.compare(version, "3.0.0")
    && :lt == Version.compare(version, "4.0.0")
  end


  # assume "Opera TV Store" to be a tv
  @is_opera_tv_store Util.build_regex("Opera TV Store")

  defp maybe_fix_opera_tv_store(%{ device: %{ type: :unknown }} = result) do
    if Regex.match?(@is_opera_tv_store, result.user_agent) do
      %{ result | device: %{ result.device | type: "tv" }}
    else
      result
    end
  end

  defp maybe_fix_opera_tv_store(result), do: result


  # assume windows 8 with touch capability is a tablet
  @has_touch Util.build_regex("Touch")

  defp maybe_fix_windows(%{ os:     %{ name: "Windows RT" },
                            device: %{ type: :unknown }} = result) do
    %{ result | device: %{ result.device | type: "tablet" }}
  end

  defp maybe_fix_windows(%{ os: %{ version: :unknown }} = result) do
    result
  end

  defp maybe_fix_windows(%{ os:     %{ name: "Windows" } = os,
                            device: %{ type: :unknown }} = result) do
    version  = Util.to_semver(os.version)
    is_gte_8 = (:lt != Version.compare(version, "8.0.0"))
    is_touch = Regex.match?(@has_touch, result.user_agent)

    if is_gte_8 && is_touch do
      %{ result | device: %{ result.device | type: "tablet" }}
    else
      result
    end
  end

  defp maybe_fix_windows(result), do: result
end
