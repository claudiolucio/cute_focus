defmodule CuteFocus.Agents do
  alias CuteFocus.Accounts.Scope

  def companion_note(%Scope{} = scope, room) do
    config = Application.get_env(:cute_focus, :agents, [])
    provider = note_provider(config)

    provider.generate_companion_note(companion_prompt(scope, room), config)
  end

  defp companion_prompt(_scope, room) do
    activity = if room.activity, do: room.activity.name, else: "no active activity"

    """
    This note is for Iza, who uses a study room called Cute Focus.
    She has completed #{room.completed_sessions} focus sessions and #{room.total_minutes} total focus minutes.
    Her room mood is #{room.mood}; her active activity is #{activity}.
    Give a warm, specific encouragement from Liro, her pixel companion.
    """
  end

  defp note_provider(config) do
    case Keyword.get(config, :opencode_url) do
      url when is_binary(url) and url != "" -> CuteFocus.Agents.OpenCode
      _ -> Keyword.get(config, :note_provider, CuteFocus.Agents.OpenAI)
    end
  end
end
