defmodule Mix.UaInspector.Download do
  @moduledoc """
  Utility module to support download tasks.
  """

  alias UaInspector.Config

  @doc """
  Prints an error because of missing configuration values.
  """
  @spec exit_unconfigured() :: no_return
  def exit_unconfigured() do
    Mix.shell.error "Database path not configured."
    Mix.shell.error "See README.md for details."
  end

  @doc """
  Prepares the local database path for downloads.
  """
  @spec prepare_database_path() :: :ok
  def prepare_database_path() do
    case File.dir?(Config.database_path) do
      true  -> document_database_path()
      false -> setup_database_path()
    end
  end

  @doc """
  Asks a user to confirm the download.

  To skip confirmation the argument `--force` can be passed to the mix task.
  """
  @spec request_confirmation(list) :: boolean
  def request_confirmation(args) do
    Mix.shell.info "Download path: #{ Config.database_path }"
    Mix.shell.info "This command will overwrite any existing files!"

    { opts, _argv, _errors } = OptionParser.parse(args, aliases: [ f: :force ])

    case opts[:force] do
      true -> true
      _    -> "Really download?" |> Mix.shell.yes?()
    end
  end


  # internal methods

  defp document_database_path() do
    readme_src = Path.join(__DIR__, "../files/README.md")
    readme_tgt = Path.join(Config.database_path, "README.md")

    File.copy! readme_src, readme_tgt

    :ok
  end

  defp setup_database_path() do
    Config.database_path |> File.mkdir_p!

    document_database_path()
  end
end
