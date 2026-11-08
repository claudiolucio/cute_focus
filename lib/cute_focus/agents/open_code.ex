defmodule CuteFocus.Agents.OpenCode do
  @behaviour CuteFocus.Agents.Provider

  @impl true
  def generate_companion_note(prompt, config) do
    with {:ok, base_url} <- server_url(config),
         {:ok, %{"id" => session_id}} <-
           request(:post, "#{base_url}/session", config, %{title: "Cute Focus Liro"}),
         {:ok, %{"parts" => parts}} <-
           request(
             :post,
             "#{base_url}/session/#{session_id}/message",
             config,
             message_body(prompt)
           ),
         {:ok, note} <- text_part(parts) do
      {:ok, note}
    end
  end

  defp server_url(config) do
    case Keyword.get(config, :opencode_url) do
      url when is_binary(url) and url != "" -> {:ok, String.trim_trailing(url, "/")}
      _ -> {:error, :not_configured}
    end
  end

  defp message_body(prompt) do
    %{parts: [%{type: "text", text: prompt}]}
  end

  defp request(method, url, config, body) do
    options = [
      method: method,
      url: url,
      json: body,
      headers: auth_headers(config),
      receive_timeout: 30_000
    ]

    case Req.request(options) do
      {:ok, %{status: status, body: response_body}} when status in 200..299 ->
        {:ok, response_body}

      {:ok, %{status: status}} ->
        {:error, {:provider_error, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp auth_headers(config) do
    case Keyword.get(config, :opencode_password) do
      password when is_binary(password) and password != "" ->
        username = Keyword.get(config, :opencode_username, "opencode")
        [{"authorization", "Basic #{Base.encode64("#{username}:#{password}")}"}]

      _ ->
        []
    end
  end

  defp text_part(parts) do
    case Enum.find(parts, &(&1["type"] == "text" and is_binary(&1["text"]))) do
      %{"text" => note} -> {:ok, String.trim(note)}
      _ -> {:error, :unexpected_response}
    end
  end
end
