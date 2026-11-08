defmodule CuteFocus.Repo.Migrations.MarkShortCompletedSessionsIncomplete do
  use Ecto.Migration

  def change do
    execute """
    UPDATE focus_sessions
    SET status = 'incomplete'
    WHERE status = 'complete' AND duration_seconds <= 2700
    """
  end
end
