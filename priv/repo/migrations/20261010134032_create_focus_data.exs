defmodule CuteFocus.Repo.Migrations.CreateFocusData do
  use Ecto.Migration

  def change do
    create table(:activities) do
      add :name, :string, null: false
      add :sprite_key, :string, null: false
      add :accent, :string, null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:activities, [:name])

    create table(:focus_sessions) do
      add :duration_seconds, :integer, null: false, default: 0
      add :status, :string, null: false, default: "active"
      add :started_at, :utc_datetime, null: false
      add :ended_at, :utc_datetime
      add :activity_id, references(:activities, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create index(:focus_sessions, [:activity_id])
  end
end
