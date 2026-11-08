defmodule CuteFocus.AgentsTest do
  use CuteFocus.DataCase

  alias CuteFocus.Accounts.Scope
  alias CuteFocus.Agents
  alias CuteFocus.Focus

  import CuteFocus.AccountsFixtures

  test "delegates a room-aware note to the configured provider" do
    user = user_fixture()
    room = Focus.room(Scope.for_user(user))

    assert {:ok, "Liro says your little room is growing with every gentle session."} =
             Agents.companion_note(Scope.for_user(user), room)
  end
end
