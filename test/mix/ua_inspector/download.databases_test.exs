defmodule Mix.UaInspector.Download.DatabasesTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  @tag :download
  test "aborted download" do
    Mix.shell(Mix.Shell.IO)

    console = capture_io fn ->
      Mix.UaInspector.Download.Databases.run([])

      IO.write "n"
    end

    assert String.contains?(console, "Download aborted")
  end

  @tag :download
  test "confirmed download" do
    Mix.shell(Mix.Shell.IO)

    console = capture_io [capture_prompt: true], fn ->
      Mix.UaInspector.Download.Databases.run([])
    end

    assert String.contains?(console, "Really download? [Yn]")
  end

  @tag :download
  test "forceable download" do
    Mix.shell(Mix.Shell.IO)

    orig_path = Application.get_env(:ua_inspector, :database_path)
    test_path = Path.join(__DIR__, "../../downloads") |> Path.expand()

    console = capture_io fn ->
      Application.put_env(:ua_inspector, :database_path, test_path)
      Mix.UaInspector.Download.Databases.run(["--force"])
      Application.put_env(:ua_inspector, :database_path, orig_path)

      databases = [
        UaInspector.Database.Bots,
        UaInspector.Database.BrowserEngines,
        UaInspector.Database.Clients,
        UaInspector.Database.Devices,
        UaInspector.Database.OSs,
        UaInspector.Database.VendorFragments
      ]

      for database <- databases do
        for { _type, local, _remote } <- database.sources do
          [ test_path, local ]
          |> Path.join()
          |> File.exists?
          |> assert
        end
      end
    end

    assert String.contains?(console, test_path)

    File.rm_rf! test_path
  end

  @tag :download
  test "missing configuration" do
    Mix.shell(Mix.Shell.IO)

    orig_path = Application.get_env(:ua_inspector, :database_path)

    console = capture_io :stderr, fn ->
      # capture regular output as well
      capture_io fn ->
        Application.put_env(:ua_inspector, :database_path, nil)
        Mix.UaInspector.Download.Databases.run([])
        Application.put_env(:ua_inspector, :database_path, orig_path)
      end
    end

    assert String.contains?(console, "not configured")
  end
end
