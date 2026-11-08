defmodule CuteFocus.Repo.Migrations.RepairMissingRoomArtworks do
  use Ecto.Migration

  def up do
    # The preceding migration creates this table; SQLite repair SQL is not portable to Postgres.
    :ok
  end

  def down do
    :ok
  end
end
