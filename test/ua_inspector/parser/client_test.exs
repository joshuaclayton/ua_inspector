defmodule UaInspector.Parser.ClientTest do
  use ExUnit.Case, async: true

  alias UaInspector.Result

  test "#1" do
    agent  = "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0; Xbox)"
    parsed = UaInspector.parse(agent)
    result = %Result.Client{ engine: "Trident", name: "Internet Explorer", type: "browser", version: "9.0" }

    assert parsed.client == result
  end

  test "#2" do
    agent  = "Mozilla/5.0 (X11; Linux x86_64; rv:10.0.12) Gecko/20130823 Firefox/10.0.11esrpre Iceape/2.7.12"
    parsed = UaInspector.parse(agent)
    result = %Result.Client{ engine: "Gecko", name: "Iceape", type: "browser", version: "2.7.12" }

    assert parsed.client == result
  end
end
