defmodule CuteFocusWeb.StatsLiveTest do
  use CuteFocusWeb.ConnCase

  import Phoenix.LiveViewTest

  test "shows the signed-in user's statistics", %{conn: conn} do
    %{conn: conn} = register_and_log_in_user(%{conn: conn})
    {:ok, view, _html} = live(conn, ~p"/stats")

    assert has_element?(view, "#stats-summary")
    assert has_element?(view, "#empty-sessions")
  end
end
