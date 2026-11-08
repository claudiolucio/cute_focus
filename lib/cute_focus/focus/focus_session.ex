defmodule CuteFocus.Focus.FocusSession do
  use Ecto.Schema
  import Ecto.Changeset

  alias CuteFocus.Accounts.User
  alias CuteFocus.Focus.Activity

  schema "focus_sessions" do
    field :duration_seconds, :integer, default: 0
    field :target_duration_seconds, :integer, default: 0
    field :status, :string, default: "active"
    field :started_at, :utc_datetime
    field :ended_at, :utc_datetime
    belongs_to :activity, Activity
    belongs_to :user, User
    timestamps(type: :utc_datetime)
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [:duration_seconds, :target_duration_seconds, :status, :started_at, :ended_at])
    |> validate_required([:duration_seconds, :target_duration_seconds, :status, :started_at])
    |> validate_number(:duration_seconds, greater_than_or_equal_to: 0)
    |> validate_number(:target_duration_seconds, greater_than: 0)
    |> foreign_key_constraint(:activity_id)
  end
end
