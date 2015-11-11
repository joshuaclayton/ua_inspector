defmodule UaInspector do
  @moduledoc """
  UaInspector Application
  """

  use Application

  alias UaInspector.Config
  alias UaInspector.Databases
  alias UaInspector.ShortCodeMaps

  def start(_type, _args) do
    import Supervisor.Spec

    options  = [ strategy: :one_for_one, name: UaInspector.Supervisor ]
    children = [
      worker(Databases, []),
      worker(ShortCodeMaps, []),
      UaInspector.Pool.child_spec
    ]

    sup = Supervisor.start_link(children, options)
    :ok = Config.database_path |> Databases.load()
    :ok = Config.database_path |> ShortCodeMaps.load()

    sup
  end


  @doc """
  Checks if a user agent is a known bot.
  """
  @spec bot?(String.t) :: boolean
  defdelegate bot?(ua), to: UaInspector.Pool

  @doc """
  Parses a user agent.
  """
  @spec parse(String.t) :: map
  defdelegate parse(ua), to: UaInspector.Pool

  @doc """
  Parses a user agent without checking for bots.
  """
  @spec parse_client(String.t) :: map
  defdelegate parse_client(ua), to: UaInspector.Pool
end
