defmodule CuteFocus.Focus do
  import Ecto.Query, warn: false

  alias CuteFocus.Accounts.Scope
  alias CuteFocus.Focus.{Activity, FocusSession}
  alias CuteFocus.Repo

  @default_activities [
    %{name: "Reading", sprite_key: "book", accent: "orange"},
    %{name: "Writing", sprite_key: "pen", accent: "yellow"},
    %{name: "Practice", sprite_key: "star", accent: "pink"},
    %{name: "Deep work", sprite_key: "lamp", accent: "blue"},
    %{name: "Review", sprite_key: "note", accent: "green"},
    %{name: "Planning", sprite_key: "clock", accent: "purple"}
  ]

  def activities do
    ensure_activities()
    Repo.all(Activity) |> Enum.sort_by(& &1.id)
  end

  def start_session(%Scope{} = scope, activity) do
    %FocusSession{}
    |> FocusSession.changeset(%{
      started_at: now(),
      duration_seconds: 0,
      status: "active"
    })
    |> Ecto.Changeset.put_change(:activity_id, activity.id)
    |> Ecto.Changeset.put_change(:user_id, scope.user.id)
    |> Repo.insert()
  end

  def finish_session(session, duration_seconds) do
    session
    |> FocusSession.changeset(%{
      duration_seconds: duration_seconds,
      status: "complete",
      ended_at: now()
    })
    |> Repo.update()
  end

  def reset_progress(%Scope{} = scope) do
    Repo.delete_all(from session in FocusSession, where: session.user_id == ^scope.user.id)
  end

  def stats(%Scope{} = scope) do
    sessions =
      Repo.all(
        from session in FocusSession,
          where: session.user_id == ^scope.user.id and session.status == "complete",
          preload: [:activity],
          order_by: [desc: session.started_at]
      )

    total_seconds = Enum.sum(Enum.map(sessions, & &1.duration_seconds))

    today_seconds =
      sessions
      |> Enum.filter(&(DateTime.to_date(&1.started_at) == Date.utc_today()))
      |> Enum.map(& &1.duration_seconds)
      |> Enum.sum()

    favorite_activity =
      sessions
      |> Enum.frequencies_by(& &1.activity.name)
      |> Enum.max_by(fn {_name, count} -> count end, fn -> {"No favorite yet", 0} end)
      |> elem(0)

    %{
      sessions: sessions,
      total_minutes: div(total_seconds, 60),
      today_minutes: div(today_seconds, 60),
      session_count: length(sessions),
      favorite_activity: favorite_activity
    }
  end

  def room(%Scope{} = scope) do
    stats = stats(scope)

    active_session =
      Repo.one(
        from session in FocusSession,
          where: session.user_id == ^scope.user.id and session.status == "active",
          preload: [:activity],
          order_by: [desc: session.started_at],
          limit: 1
      )

    %{
      mood: room_mood(active_session, stats.session_count),
      activity: active_session && active_session.activity,
      completed_sessions: stats.session_count,
      level: stats.session_count,
      total_minutes: stats.total_minutes,
      unlocked: %{
        plant: stats.session_count >= 1,
        cat: stats.session_count >= 3,
        books: stats.session_count >= 5,
        poster: stats.session_count >= 8
      }
    }
  end

  defp ensure_activities do
    Enum.each(@default_activities, fn attributes ->
      Activity.changeset(%Activity{}, attributes)
      |> Repo.insert(on_conflict: :nothing, conflict_target: :name)
    end)
  end

  defp now, do: DateTime.utc_now() |> DateTime.truncate(:second)

  defp room_mood(nil, 0), do: :resting
  defp room_mood(nil, _completed_sessions), do: :celebrating
  defp room_mood(_active_session, _completed_sessions), do: :studying
end
