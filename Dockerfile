FROM hexpm/elixir:1.17.3-erlang-27.3.4.19-debian-bookworm-20261104-slim AS build

RUN apt-get update -y && apt-get install -y --no-install-recommends build-essential git && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENV MIX_ENV=prod

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

COPY config config
RUN mix deps.compile

COPY assets assets
COPY lib lib
COPY priv priv
RUN mix assets.deploy && mix release

FROM debian:bookworm-slim AS app

RUN apt-get update -y && apt-get install -y --no-install-recommends ca-certificates libstdc++6 openssl && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN groupadd --system app && useradd --system --gid app --home-dir /app app

ENV HOME=/app \
    LANG=C.UTF-8 \
    MIX_ENV=prod \
    PHX_SERVER=true

COPY --from=build --chown=app:app /app/_build/prod/rel/cute_focus ./
USER app

CMD ["bin/cute_focus", "start"]
