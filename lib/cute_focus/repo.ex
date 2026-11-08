defmodule CuteFocus.Repo do
  use Ecto.Repo,
    otp_app: :cute_focus,
    adapter: Ecto.Adapters.Postgres
end
