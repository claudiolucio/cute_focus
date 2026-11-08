defmodule CuteFocusWeb.RoomLiveTest do
  use CuteFocusWeb.ConnCase

  import Phoenix.LiveViewTest

  test "shows the signed-in user's room and first unlock", %{conn: conn} do
    %{conn: conn} = register_and_log_in_user(%{conn: conn})
    {:ok, view, _html} = live(conn, ~p"/room")

    assert has_element?(view, "#room-scene[data-room-mood='resting']")
    assert has_element?(view, "#room-level", "LV 0")
    assert has_element?(view, "#room-session-count", "0")
    assert has_element?(view, "#room-next-unlock", "a tiny desk plant")
    assert has_element?(view, "#room-reset")
  end

  test "asks the companion for an agent-generated note", %{conn: conn} do
    %{conn: conn} = register_and_log_in_user(%{conn: conn})
    {:ok, view, _html} = live(conn, ~p"/room")

    view |> element("#ask-companion") |> render_click()

    assert has_element?(view, "#companion-note", "Liro says your little room is growing")
  end
end
