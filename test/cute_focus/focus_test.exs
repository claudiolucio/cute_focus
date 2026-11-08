defmodule CuteFocus.FocusTest do
  use CuteFocus.DataCase

  alias CuteFocus.Accounts.Scope
  alias CuteFocus.Focus

  import CuteFocus.AccountsFixtures

  test "returns only the signed-in user's completed session statistics" do
    user = user_fixture()
    other_user = user_fixture()
    activity = Focus.activities() |> List.first()

    {:ok, session} = Focus.start_session(Scope.for_user(user), activity, 3_600)
    {:ok, _session} = Focus.finish_session(session, 3_600)

    {:ok, other_session} = Focus.start_session(Scope.for_user(other_user), activity, 3_600)
    {:ok, _session} = Focus.finish_session(other_session, 3_600)

    stats = Focus.stats(Scope.for_user(user))

    assert stats.session_count == 1
    assert stats.total_minutes == 60
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

    {:ok, session} = Focus.start_session(Scope.for_user(user), activity, 3_600)
    {:ok, _session} = Focus.finish_session(session, 3_600)

    {:ok, other_session} = Focus.start_session(Scope.for_user(other_user), activity, 3_600)
    {:ok, _session} = Focus.finish_session(other_session, 3_600)

    assert {1, _} = Focus.reset_progress(Scope.for_user(user))
    assert Focus.stats(Scope.for_user(user)).session_count == 0
    assert Focus.stats(Scope.for_user(other_user)).session_count == 1
  end

  test "does not count short or unfinished sessions as complete" do
    user = user_fixture()
    activity = Focus.activities() |> List.first()

    {:ok, short_session} = Focus.start_session(Scope.for_user(user), activity, 45 * 60)
    {:ok, short_session} = Focus.finish_session(short_session, 45 * 60)

    {:ok, unfinished_session} = Focus.start_session(Scope.for_user(user), activity, 60 * 60)
    {:ok, unfinished_session} = Focus.finish_session(unfinished_session, 30 * 60)

    assert short_session.status == "incomplete"
    assert unfinished_session.status == "incomplete"
    assert Focus.stats(Scope.for_user(user)).session_count == 0
  end
end
