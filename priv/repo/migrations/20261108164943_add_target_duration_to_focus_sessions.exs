defmodule CuteFocus.Repo.Migrations.AddTargetDurationToFocusSessions do
  use Ecto.Migration

  def change do
    alter table(:focus_sessions) do
      add :target_duration_seconds, :integer, null: false, default: 0
    end
  end
end
