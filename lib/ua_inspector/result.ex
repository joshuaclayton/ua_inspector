defmodule UaInspector.Result do
  @moduledoc """
  Result struct.
  """

  alias UaInspector.Result

  defstruct [
    user_agent: "",
    client:     :unknown,
    device:     %Result.Device{},
    os:         :unknown
  ]
end
