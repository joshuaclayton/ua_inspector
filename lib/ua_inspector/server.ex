defmodule UaInspector.Server do
  @moduledoc """
  UaInspector poolboy worker (server).
  """

  use GenServer

  @behaviour :poolboy_worker

  def start_link(default \\ %{}) do
    GenServer.start_link(__MODULE__, default)
  end

  def handle_call({ :is_bot, ua }, _from, state) do
    { :reply, UaInspector.Parser.bot?(ua), state }
  end

  def handle_call({ :parse, ua }, _from, state) do
    { :reply, UaInspector.Parser.parse(ua), state }
  end

  def handle_call({ :parse_client, ua }, _from, state) do
    { :reply, UaInspector.Parser.parse_client(ua), state }
  end
end
