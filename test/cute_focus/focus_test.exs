defmodule CuteFocus.FocusTest do
  use CuteFocus.DataCase

  alias CuteFocus.Accounts.Scope
  alias CuteFocus.Focus

  import CuteFocus.AccountsFixtures

  test "returns only the signed-in user's completed session statistics" do
    user = user_fixture()
    other_user = user_fixture()
    activity = Focus.activities() |> List.first()

    {:ok, session} = Focus.start_session(Scope.for_user(user), activity)
    {:ok, _session} = Focus.finish_session(session, 1_500)

    {:ok, other_session} = Focus.start_session(Scope.for_user(other_user), activity)
    {:ok, _session} = Focus.finish_session(other_session, 900)

    stats = Focus.stats(Scope.for_user(user))

    assert stats.session_count == 1
    assert stats.total_minutes == 25
    assert stats.favorite_activity == activity.name

    room = Focus.room(Scope.for_user(user))
    assert room.mood == :celebrating
    assert room.level == 1
    assert room.unlocked.plant
    refute room.unlocked.cat
  end

  test "resets only the current user's focus progress" do
    user = user_fixture()
    other_user = user_fixture()
    activity = Focus.activities() |> List.first()

    {:ok, session} = Focus.start_session(Scope.for_user(user), activity)
    {:ok, _session} = Focus.finish_session(session, 1_500)

    {:ok, other_session} = Focus.start_session(Scope.for_user(other_user), activity)
    {:ok, _session} = Focus.finish_session(other_session, 1_500)

    assert {1, _} = Focus.reset_progress(Scope.for_user(user))
    assert Focus.stats(Scope.for_user(user)).session_count == 0
    assert Focus.stats(Scope.for_user(other_user)).session_count == 1
  end
end
