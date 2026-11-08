defmodule CuteFocus.Agents.FakeProvider do
  @behaviour CuteFocus.Agents.Provider

  @impl true
  def generate_companion_note(_prompt, _config),
    do: {:ok, "Liro says your little room is growing with every gentle session."}
end
