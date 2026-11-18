# From Sensor to Insight: Real-Time IoT Analytics with TimescaleDB

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/timescale/sensor-to-insight-workshop)

A 60-minute hands-on workshop where you'll build a real IoT analytics pipeline on Tiger Cloud from scratch. You write the SQL, you run the queries, and you walk away with a working service you built yourself.

## What you'll learn

- **Hypertables** — turn a regular Postgres table into a time-series-optimized one
- **Columnar compression** — typically 5–10× storage reduction *and* faster queries
- **Continuous aggregates** — self-updating materialized views for real-time dashboards
- **Time-series queries** — `time_bucket()` and hyperfunctions like `last()`
- **Retention policies** — drop old data automatically

## Before the workshop — setup checklist

You need three things before we start. Do these **before workshop day** — workshop day is a bad time to debug DNS.

> **Using GitHub Codespaces?** Click the badge above and you get a terminal with the
> `tiger` CLI already installed and configured. That's the whole toolchain — every SQL
> statement in this workshop runs through `tiger db query`, so there is no `psql` to
> install and no connection string to copy around.

### 1. Sign up for Tiger Cloud

Sign up at [tsdb.co/sensor-workshop-signup](https://tsdb.co/sensor-workshop-signup). You'll get **$1000 in trial credit**, which is way more than enough for this workshop and a bunch of follow-up experimentation.

### 2. Log in to the CLI

```bash
tiger auth login --headless
```

`--headless` prints a short code and a URL. Open the URL in any browser on any machine,
enter the code, pick your project. This is the flow designed for exactly this situation —
your terminal is in a container in a datacenter and can't open your browser.

Check it worked:

```bash
tiger service list
```

### 3. Create your service

```bash
tiger service create --name iot-workshop --cpu 500 --memory 2
```

That's the smallest paid SKU (0.5 CPU / 2 GB); your trial credits cover it comfortably.
This workshop generates about 15.5 million rows, which is more than a free service will
hold.

**Creating a service also makes it your default**, which is why nothing below needs a
service ID or a connection string. If you ever need to point at a different service, pass
its ID: `tiger db query <service-id> -c "..."`.

To make a different service your default instead (for example, one you created before the
workshop), find its ID with `tiger service list` and set it:

```bash
tiger config set service_id <service-id>
```

### 4. Test it

A few days before the workshop, run:

```bash
tiger db query -c "SELECT version()"
```

If you see a Postgres version string, you're set. If not, sort it out before workshop day.

---

### Not using Codespaces?

Everything above works the same on your own machine once the CLI is installed:

```bash
# macOS / Linux / WSL
curl -fsSL https://cli.tigerdata.com | sh

# Or via Homebrew
brew install --cask timescale/tap/tiger-cli

# Windows (PowerShell)
irm https://cli.tigerdata.com/install.ps1 | iex
```

**On Linux without a desktop keyring**, `tiger auth login` can appear to succeed and then
every later command fails to read the credentials back. Fix it before logging in:

```bash
tiger config set password_storage pgpass
```

The Codespace does this for you.

**Prefer not to use a terminal at all?** You can run every statement in this workshop from
the [**Data** tab in the Tiger Cloud console](https://www.tigerdata.com/docs/build/data-management/run-queries-from-tiger-console#data-view)
instead, and create the service through the console UI rather than the CLI.

---

## During the workshop

We'll work through the files in the [`sql`](./sql) directory, step by step.

**Recommended:** open each `*.sql` file and run one section at a time, so you can read the
output as we go. The easiest way is to [run a selection from the editor](#running-a-selection-from-the-editor);
you can also paste a statement into the terminal:

```bash
tiger db query -c "SELECT * FROM tag_meta"
```

### Running a selection from the editor

In the Codespace (or any VS Code window open on this repo) you don't have to copy SQL into
the terminal. Highlight the lines you want to run in any `.sql` file, then either:

- press **Ctrl+Shift+B** (**Cmd+Shift+B** on a Mac), or
- choose **Terminal → Run Build Task…** from the menu.

The highlighted SQL runs through `tiger db query` and the output appears in the terminal
panel. With nothing highlighted, the whole file runs.

How it works: [`.vscode/tasks.json`](./.vscode/tasks.json) defines a **Run SQL with Tiger
CLI** task and makes it the default build task, which is what puts it on Ctrl+Shift+B. The
task hands the highlighted text to [`.vscode/run-sql.sh`](./.vscode/run-sql.sh), which
writes it to a temporary file and runs `tiger db query -f` on it. Your SQL never passes
through the shell, so quotes, semicolons and `$` signs are safe.

Because it uses `-f`, highlighting several statements runs them together in one
transaction. That's fine for everything except creating the continuous aggregate (see
below), which is why that statement has a file of its own.

### To run a whole file at once

Copy and paste whichever file you need:

```bash
tiger db query -f sql/1-create_tables.sql
```

```bash
tiger db query -f sql/2-generate_data.sql
```

```bash
tiger db query -f sql/3-inspect_hypertables.sql
```

```bash
tiger db query -f sql/4a-query_data.sql
```

```bash
tiger db query -f sql/4b-create_continuous_aggregate.sql
```

```bash
tiger db query -f sql/4c-query_continuous_aggregate.sql
```

```bash
tiger db query -f sql/5-data_retention_policy.sql
```

Two things worth knowing:

- `sql/2-generate_data.sql` builds ~15.5 million rows and takes about **4 minutes** on the
  0.5 CPU service. It hasn't hung.
- Step 4 is split across three files so that `sql/4b-create_continuous_aggregate.sql`
  holds a single statement. `tiger db query` runs a file with several statements as one
  transaction, and creating a continuous aggregate can't happen inside one; you'd get
  `ERROR: cannot run inside a transaction block (SQLSTATE 25001)`. On its own it runs
  fine. The same applies when highlighting: don't select the `DROP` in `4a` and the
  `CREATE` in `4b` together.

**Alternative:** paste the whole file into the **Data** tab in the Tiger Cloud console.

If you fall behind on a step, the next one will still work — each section is self-contained.

## Need help?

- **Workshop day:** ask in the Zoom chat
- **Anytime:** [docs.tigerdata.com](https://tigerdata.com/docs) or [Community Slack](https://slack.timescale.com)

## After the workshop

Your service stays up — keep playing. Some ideas:

- **Try the Tiger MCP with your AI assistant of choice.** Once `tiger-cli` is installed, `tiger mcp install` wires it into Claude Code, Cursor, Windsurf, Codex, Gemini CLI, or VS Code automatically. (Claude Desktop is a manual JSON edit — see the [Tiger MCP docs](https://www.tigerdata.com/docs/get-started/quickstart/mcp-cli).) Then ask your assistant to query the hypertable you just built.
- Plug Grafana into your service and build a dashboard.
- Try [tiered storage to S3](https://docs.tigerdata.com/use-timescale/latest/data-tiering/) (we skipped it for time).
- Bring your own data and convert an existing Postgres table into a hypertable.

When your trial credits run out, the smallest paid service is a few bucks a month.
