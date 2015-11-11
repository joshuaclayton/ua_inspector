defmodule UaInspector.Database.Clients do
  @moduledoc """
  UaInspector client information database.
  """

  use UaInspector.Database

  alias UaInspector.Util

  # files ordered according to
  # https://github.com/piwik/device-detector/blob/master/DeviceDetector.php
  # to prevent false detections
  @source_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/regexes/client"
  @sources         [
    { "feed reader", "clients.feed_readers.yml", "#{ @source_base_url }/feed_readers.yml" },
    { "mobile app",  "clients.mobile_apps.yml",  "#{ @source_base_url }/mobile_apps.yml" },
    { "mediaplayer", "clients.mediaplayers.yml", "#{ @source_base_url }/mediaplayers.yml" },
    { "pim",         "clients.pim.yml",          "#{ @source_base_url }/pim.yml" },
    { "browser",     "clients.browsers.yml",     "#{ @source_base_url }/browsers.yml" },
    { "library",     "clients.libraries.yml",    "#{ @source_base_url }/libraries.yml" }
  ]

  @ets_counter :clients
  @ets_table   :ua_inspector_database_clients

  def store_entry(data, type) do
    counter = UaInspector.Databases.update_counter(@ets_counter)
    data    = Enum.into(data, %{})

    entry = %{
      engine:  data["engine"],
      name:    data["name"],
      regex:   Util.build_regex(data["regex"]),
      type:    type,
      version: data["version"] |> to_string()
    }

    :ets.insert_new(@ets_table, { counter, entry })
  end
end
