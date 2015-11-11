defmodule UaInspector.ShortCodeMaps do
  @moduledoc """
  Module to coordinate individual parser short code maps.
  """

  use GenServer

  alias UaInspector.ShortCodeMap


  # GenServer lifecycle

  @doc """
  Starts the database server.
  """
  @spec start_link(any) :: GenServer.on_start
  def start_link(default \\ []) do
    GenServer.start_link(__MODULE__, default, [ name: __MODULE__ ])
  end

  def init(_) do
    _ = ShortCodeMap.DeviceBrands.init()
    _ = ShortCodeMap.OSs.init()

    { :ok, [] }
  end


  # GenServer callbacks

  def handle_call({ :load, path }, _from, state) do
    :ok = ShortCodeMap.DeviceBrands.load(path)
    :ok = ShortCodeMap.OSs.load(path)

    { :reply, :ok, state }
  end


  # Convenience methods

  @doc """
  Sends a request to load a database to the internal server.
  """
  @spec load(String.t) :: :ok
  def load(nil),  do: :ok
  def load(path), do: GenServer.call(__MODULE__, { :load, path })
end
