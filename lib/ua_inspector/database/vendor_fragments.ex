defmodule UaInspector.Database.VendorFragments do
  @moduledoc """
  UaInspector vendor fragment information database.
  """

  use UaInspector.Database

  alias UaInspector.Util

  @source_base_url "https://raw.githubusercontent.com/piwik/device-detector/master/regexes"
  @sources         [{ "", "vendorfragments.yml", "#{ @source_base_url }/vendorfragments.yml" }]

  @ets_counter :vendor_fragments
  @ets_table   :ua_inspector_database_vendor_fragments

  def store_entry({ brand, regexes }, _type) do
    counter = UaInspector.Databases.update_counter(@ets_counter)
    regexes = regexes |> Enum.map( &Util.build_regex/1 )

    entry = %{
      brand:   brand,
      regexes: regexes
    }

    :ets.insert_new(@ets_table, { counter, entry })
  end
end
