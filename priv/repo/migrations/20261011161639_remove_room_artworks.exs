defmodule CuteFocus.Repo.Migrations.RemoveRoomArtworks do
  use Ecto.Migration

  def up do
    drop table(:room_artworks)
  end

  def down do
    create table(:room_artworks) do
      add :prompt, :string, null: false
      add :image_data, :binary, null: false
      add :content_type, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:room_artworks, [:user_id, :inserted_at])
  end
end
