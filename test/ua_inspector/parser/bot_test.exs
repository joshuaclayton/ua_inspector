defmodule UaInspector.Parser.BotTest do
  use ExUnit.Case, async: true

  alias UaInspector.Result

  test "#1" do
    agent  = "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; Googlebot/2.1; +http://www.google.com/bot.html) Safari/537.36"
    parsed = UaInspector.parse(agent)

    assert "Search bot" == parsed.category
    assert "http://www.google.com" == parsed.producer.url
  end

  test "#2" do
    agent  = "generic crawler agent"
    parsed = UaInspector.parse(agent)
    result = %Result.Bot{ user_agent: agent, name: "Generic Bot" }

    assert parsed == result
  end
end
