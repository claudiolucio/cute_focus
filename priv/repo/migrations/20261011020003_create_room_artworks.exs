defmodule CuteFocus.Repo.Migrations.CreateRoomArtworks do
  use Ecto.Migration

  def change do
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
