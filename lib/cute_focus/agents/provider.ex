defmodule CuteFocus.Agents.Provider do
  @callback generate_companion_note(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
end
