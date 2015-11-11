defmodule Mix.UaInspector.Download.ShortCodeMaps do
  @moduledoc """
  Fetches short code map listings from the
  [piwik/device-detector](https://github.com/piwik/device-detector)
  project.

  The listings are extracted from the original PHP source files and stored
  as YAML files in the configured download path.

  `mix ua_inspector.download.short_code_maps`
  """

  alias Mix.UaInspector.Download
  alias Mix.UaInspector.ShortCodeMap, as: Util

  alias UaInspector.Config
  alias UaInspector.ShortCodeMap


  @behaviour Mix.Task

  def run(args) do
    Mix.shell.info "UaInspector Short Code Map Download"

    case Config.database_path do
      nil -> Download.exit_unconfigured()
      _   -> Download.request_confirmation(args) |> run_confirmed()
    end
  end



  defp run_confirmed(false) do
    Mix.shell.info "Download aborted!"

    :ok
  end

  defp run_confirmed(true) do
    :ok = Download.prepare_database_path()
    :ok =
         [ ShortCodeMap.DeviceBrands, ShortCodeMap.OSs ]
      |> download()

    Mix.shell.info "Download complete!"

    :ok
  end

  defp download([]),            do: :ok
  defp download([ map | maps ]) do
    Mix.shell.info ".. downloading: #{ map.local }"

    yaml = Path.join([ Config.database_path, map.local ])
    temp = "#{ yaml }.tmp"

    download_database(map.remote, temp)

    :ok =
         map.var
      |> Util.extract(temp)
      |> Util.write_yaml(yaml)

    File.rm! temp

    download(maps)
  end

  if Version.match?(System.version, ">= 1.1.0") do
    defp download_database(remote, local) do
      { :ok, content } = Mix.Utils.read_path(remote)

      File.write! local, content
    end
  else
    defp download_database(remote, local) do
      File.write! local, Mix.Utils.read_path!(remote)
    end
  end
end
