defmodule UaInspector.Result.OS do
  @moduledoc """
  Operating system result struct.
  """

  defstruct [
    name:     :unknown,
    platform: :unknown,
    version:  :unknown
  ]
end
