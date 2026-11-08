defmodule CuteFocusWeb.FocusLiveTest do
  use CuteFocusWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders the focus display", %{conn: conn} do
    %{conn: conn} = register_and_log_in_user(%{conn: conn})
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "#focus-timer")
    assert has_element?(view, "#activities")
    assert has_element?(view, "#start-focus")
    assert has_element?(view, "#focus-audio[phx-hook='FocusAudio']")
  end

  test "changes the selected activity", %{conn: conn} do
    %{conn: conn} = register_and_log_in_user(%{conn: conn})
    {:ok, view, _html} = live(conn, ~p"/")
    view |> element("#activities [data-activity='Writing']") |> render_click()
    assert has_element?(view, "#selected-activity", "Writing")
    assert has_element?(view, "[data-activity='Writing'][aria-pressed]")
  end

  test "starts and pauses a focus session", %{conn: conn} do
    %{conn: conn} = register_and_log_in_user(%{conn: conn})
    {:ok, view, _html} = live(conn, ~p"/")
    view |> element("#start-focus") |> render_click()
    assert has_element?(view, "#pause-focus:not([disabled])")
    view |> element("#pause-focus") |> render_click()
    assert has_element?(view, "#start-focus:not([disabled])")
  end
end
