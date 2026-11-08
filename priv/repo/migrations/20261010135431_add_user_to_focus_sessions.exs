defmodule CuteFocus.Repo.Migrations.AddUserToFocusSessions do
  use Ecto.Migration

  def change do
    alter table(:focus_sessions) do
      add :user_id, references(:users, on_delete: :delete_all)
    end

    create index(:focus_sessions, [:user_id])
  end
end
