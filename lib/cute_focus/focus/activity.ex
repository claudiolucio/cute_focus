defmodule CuteFocus.Focus.Activity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "activities" do
    field :name, :string
    field :sprite_key, :string
    field :accent, :string
    timestamps(type: :utc_datetime)
  end

  def changeset(activity, attrs) do
    activity
    |> cast(attrs, [:name, :sprite_key, :accent])
    |> validate_required([:name, :sprite_key, :accent])
    |> unique_constraint(:name)
  end
end
