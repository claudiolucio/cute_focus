# CuteFocus

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## PostgreSQL

CuteFocus uses PostgreSQL in every environment. Start a local PostgreSQL server, then create the development and test databases with:

```bash
mix ecto.create
MIX_ENV=test mix ecto.create
```

The local default is `postgres` at `localhost:5432` without a password, matching the Docker PostgreSQL setup. Override it with `PGUSER`, `PGPASSWORD`, `PGHOST`, or `PGDATABASE` when your server uses different credentials.

Run `mix ecto.migrate` after pulling new migrations. The former SQLite database files are not used or imported automatically.

## Docker

The production image is built from `Dockerfile`; `compose.yaml` starts the application with PostgreSQL and runs migrations before the web process. Copy the environment template, generate a secret, and fill in the Gmail app password before starting it:

```bash
cp .env.example .env
mix phx.gen.secret
docker compose up --build
```

Set the generated value as `SECRET_KEY_BASE` in `.env`. The application is then available at `http://localhost:4000`.

## CI/CD

GitHub Actions runs the test suite for pull requests and pushes to `main` or `master`. A push to either branch also publishes immutable SHA-tagged and `latest` images to `ghcr.io/<github-owner>/cute-focus`. Add the project to GitHub and push the branch to activate the workflow. Configure the GitHub package visibility in GitHub if the image should be public.

## Heroku deployment

The repository includes a `Procfile`, release migration task, and `elixir_buildpack.config` for Heroku. Install the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli), authenticate, and create an app from this repository:

```bash
heroku login
heroku create cute-focus
heroku buildpacks:set hashnuke/elixir --app cute-focus
```

In the Heroku dashboard, open the app's **Resources** tab, add **Heroku Postgres**, and select the least expensive plan that fits your student-credit budget. Heroku then sets `DATABASE_URL` automatically.

Set the production configuration, replacing `cute-focus-<id>.herokuapp.com` with the domain displayed by Heroku:

```bash
heroku config:set MIX_ENV=prod PHX_SERVER=true --app cute-focus
heroku config:set PHX_HOST=cute-focus-<id>.herokuapp.com --app cute-focus
heroku config:set SECRET_KEY_BASE="$(mix phx.gen.secret)" --app cute-focus
heroku config:set OPENAI_API_KEY="your-key" --app cute-focus
```

`OPENAI_API_KEY` is optional. Do not set `OPENCODE_URL` for the local OpenCode server on Heroku: it is intentionally bound to your local machine.

### Email authentication

Production sends registration and login links through Gmail SMTP. Enable two-step verification on the Gmail account, then create a [Google app password](https://myaccount.google.com/apppasswords). Configure it through the Heroku CLI:

```bash
heroku config:set SMTP_USERNAME="your-email@gmail.com" MAILER_FROM="your-email@gmail.com" --app cute-focus
read -rs smtp_password
heroku config:set SMTP_PASSWORD="$smtp_password" --app cute-focus >/dev/null
unset smtp_password
```

The `read` command waits for the app password without displaying it. Press Enter after entering the 16-character password.

Commit the changes and deploy:

```bash
git add .
git commit -m "Prepare Heroku deployment"
git push heroku main
```

Heroku builds the Phoenix assets, creates the release, runs migrations once in the `release` process, then starts the web process. Check the deployed app and its logs with:

```bash
heroku open --app cute-focus
heroku logs --tail --app cute-focus
```

## Companion Agent

The My Room Companion uses OpenAI to create short, personalized notes from the signed-in user's focus and room data. Set these variables before starting the server:

```bash
export OPENAI_API_KEY="your-key"
export OPENAI_MODEL="gpt-4.1-mini"
mix phx.server
```

`OPENAI_MODEL` is optional. Without `OPENAI_API_KEY`, the app remains usable and the Companion button shows a retry message instead of sending a request.

The variables must be exported in the same terminal session that starts Phoenix. Restart the server after changing them.

### OpenCode Companion

To use the local OpenCode server only for Liro's text notes, start it separately and point Cute Focus to it:

```bash
OPENCODE_SERVER_PASSWORD="choose-a-password" opencode serve --hostname 127.0.0.1 --port 4096
export OPENCODE_URL="http://127.0.0.1:4096"
export OPENCODE_SERVER_PASSWORD="choose-a-password"
mix phx.server
```

Cute Focus never starts or exposes OpenCode. Keep it bound to `127.0.0.1`. Image generation remains independently configured through `OPENAI_API_KEY`.

Ready to run in production? Please [check our deployment guides](https://phoenix.hexdocs.pm/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://phoenix.hexdocs.pm/overview.html
* Docs: https://phoenix.hexdocs.pm
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
