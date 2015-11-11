defmodule UaInspector.Database.Bots do
  @moduledoc """
  UaInspector bot information database.
  """

  use UaInspector.Database

  alias UaInspector.Util

  @source_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/regexes"
  @sources         [{ "", "bots.yml", "#{ @source_base_url }/bots.yml" }]

  @ets_counter :bots
  @ets_table   :ua_inspector_database_bots

  def store_entry(data, _type) do
    counter = UaInspector.Databases.update_counter(@ets_counter)
    data    = Enum.into(data, %{})

    entry = %{
      category: data["category"],
      name:     data["name"],
      producer: producer_info(data["producer"]),
      regex:    Util.build_regex(data["regex"]),
      url:      data["url"]
    }

    :ets.insert_new(@ets_table, { counter, entry })
  end

  defp producer_info(nil), do: nil
  defp producer_info(info) do
    info = Enum.into(info, %{})

    %{ name: info["name"], url: info["url"] }
  end
end
