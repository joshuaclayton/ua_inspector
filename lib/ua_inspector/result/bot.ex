defmodule UaInspector.Result.Bot do
  @moduledoc """
  Bot result struct.
  """

  defstruct [
    user_agent: "",
    name:       :unknown,
    category:   :unknown,
    url:        :unknown,
    producer:   %UaInspector.Result.BotProducer{}
  ]
end
