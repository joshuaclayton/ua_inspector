defmodule UaInspector.Config do
  @moduledoc """
  Utility module to simplify access to configuration values.
  """

  @doc """
  Returns the configured database path or `nil`.
  """
  @spec database_path :: String.t | nil
  def database_path do
    case Application.get_env(:ua_inspector, :database_path, nil) do
      nil  -> nil
      path -> path |> Path.expand()
    end
  end
end
