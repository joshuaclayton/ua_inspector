defmodule UaInspector.Database.OSs do
  @moduledoc """
  UaInspector operating system information database.
  """

  use UaInspector.Database

  alias UaInspector.Util

  @source_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/regexes"
  @sources         [{ "", "oss.yml", "#{ @source_base_url }/oss.yml" }]

  @ets_counter :oss
  @ets_table   :ua_inspector_database_oss

  def store_entry(data, _type) do
    counter = UaInspector.Databases.update_counter(@ets_counter)
    data    = Enum.into(data, %{})

    entry = %{
      name:    data["name"],
      regex:   Util.build_regex(data["regex"]),
      version: data["version"]
    }

    :ets.insert_new(@ets_table, { counter, entry })
  end
end
