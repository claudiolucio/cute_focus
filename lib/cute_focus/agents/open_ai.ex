defmodule CuteFocus.Agents.OpenAI do
  @behaviour CuteFocus.Agents.Provider

  @impl true
  def generate_companion_note(prompt, config) do
    case Keyword.get(config, :openai_api_key) do
      nil -> {:error, :not_configured}
      "" -> {:error, :not_configured}
      api_key -> request_note(prompt, api_key, Keyword.fetch!(config, :openai_model))
    end
  end

  defp request_note(prompt, api_key, model) do
    case Req.post("https://api.openai.com/v1/chat/completions",
           headers: [{"authorization", "Bearer #{api_key}"}],
           json: %{
             model: model,
             max_tokens: 90,
             temperature: 0.9,
             messages: [
               %{
                 role: "system",
                 content:
                   "You are Liro, a kind tiny pixel companion. Write one encouraging sentence of at most 22 words. Never use markdown."
               },
               %{role: "user", content: prompt}
             ]
           }
         ) do
      {:ok, %{status: 200, body: %{"choices" => [%{"message" => %{"content" => note}} | _]}}} ->
        {:ok, String.trim(note)}

      {:ok, %{status: status, body: body}} ->
        {:error, {:provider_error, status, provider_message(body)}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp provider_message(%{"error" => %{"message" => message}}) when is_binary(message),
    do: message

  defp provider_message(_body), do: nil
end
