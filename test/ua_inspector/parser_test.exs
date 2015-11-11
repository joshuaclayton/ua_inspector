defmodule UaInspector.ParserTest do
  use ExUnit.Case, async: true

  alias UaInspector.Result

  test "handle incomplete yaml definitions" do
    agent  = "Incomplete YAML entry without model"
    parsed = %Result{
      user_agent: agent,
      device:     %Result.Device{ brand: "Incomplete" }
    }

    assert parsed == UaInspector.parse(agent)
  end

  test "parse empty" do
    agent  = ""
    parsed = %Result{ user_agent: agent }

    assert parsed == UaInspector.parse(agent)
  end

  test "parse unknown" do
    agent  = "some unknown user agent"
    parsed = %Result{ user_agent: agent }

    assert parsed == UaInspector.parse(agent)
  end


  test "bot?" do
    assert UaInspector.bot?("generic crawler agent")
    refute UaInspector.bot?("regular user agent")
  end

  test "parse" do
    agent  = "Mozilla/5.0 (iPad; CPU OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53"
    parsed = %Result{
      user_agent: agent,
      client:     %Result.Client{ engine: "WebKit", name: "Mobile Safari", type: "browser", version: "7.0" },
      device:     %Result.Device{ brand: "Apple", model: "iPad", type: "tablet" },
      os:         %Result.OS{ name: "iOS", version: "7.0.4" }
    }

    assert parsed == UaInspector.parse(agent)
  end

  test "parse_client" do
    agent  = "generic crawler agentx"
    parsed = %Result{ user_agent: agent }

    assert parsed == UaInspector.parse_client(agent)
  end
end
