# Solara

Self-hosted daily planner. Plan your day, track your time, own your data.

A Sunsama-inspired task manager built for developers who want full control over their productivity system. API-first design enables AI agent integration via MCP.

## Features

### Core
- **Daily Planning** — Guided morning ritual: review yesterday, pull from backlog, check workload
- **Daily Shutdown** — End-of-day review with stats, task rollover, and reflection
- **Task Management** — Create, schedule, prioritize, and track tasks with rich text notes
- **Channels & Contexts** — Organize tasks by project (#product, #engineering) and context (Work, Personal)
- **Unified Calendar** — Google Calendar events displayed alongside tasks in a timeline view
- **Timeboxing** — Working sessions that map tasks to time blocks on the calendar
- **Backlog** — Undated task list for someday/maybe items
- **Weekly Objectives** — High-level weekly goals linked to daily tasks
- **Timer** — Stopwatch and Pomodoro timer with per-task time tracking
- **Focus Mode** — Dedicated single-task view with timer and notes editor

### Technical
- **API-first** — Full REST API (`/api/v1/`) with Bearer token auth for every feature
- **MCP-ready** — Designed for AI agent access via Model Context Protocol
- **PWA** — Installable as a native-feeling app on macOS, iOS, Android
- **Self-hosted** — Runs on your own server, your data stays with you
- **Lightweight** — ~2.5GB RAM footprint, runs on modest hardware

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Ruby on Rails 8.0 |
| Frontend | Hotwire (Turbo + Stimulus) |
| CSS | Tailwind CSS v4 |
| Database | PostgreSQL 16 |
| Background Jobs | Solid Queue (Rails 8 built-in) |
| Rich Text | ActionText (Trix) |
| File Storage | ActiveStorage (local disk) |
| Auth | Devise |
| Calendar | Google Calendar API v3 |
| Deploy | Docker Compose |

## Requirements

- Ruby 3.2+
- PostgreSQL 14+
- Node.js is **not** required (uses importmap)

## Quick Start

### Local Development

```bash
# Clone
git clone https://github.com/Putzeys/solara.git
cd solara

# Install dependencies
bundle install

# Setup database
bin/rails db:create db:migrate db:seed

# Build CSS + start server
bin/dev
```

Open `http://localhost:3000` and sign in:
- **Email:** `admin@solara.local`
- **Password:** `password`

### Docker (Production)

```bash
# Copy environment template
cp .env.example .env
# Edit .env with your values (POSTGRES_PASSWORD, RAILS_MASTER_KEY, SECRET_KEY_BASE)

# Build and start
docker compose up -d

# Setup database (first time only)
docker compose exec web bin/rails db:setup
```

The app runs on `127.0.0.1:3000`. Use nginx or Caddy as a reverse proxy with HTTPS.

## API

All endpoints require a Bearer token (found in Settings):

```bash
# List today's tasks
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:3000/api/v1/tasks/today

# Create a task
curl -X POST -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "Review PR", "scheduled_date": "2026-04-01", "planned_minutes": 30}' \
  http://localhost:3000/api/v1/tasks

# Complete a task
curl -X POST -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:3000/api/v1/tasks/1/complete
```

### Available Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/v1/tasks` | List tasks (filters: date, channel_id, status) |
| GET | `/api/v1/tasks/today` | Today's tasks |
| GET | `/api/v1/tasks/backlog` | Backlog tasks |
| POST | `/api/v1/tasks` | Create task |
| PATCH | `/api/v1/tasks/:id` | Update task |
| DELETE | `/api/v1/tasks/:id` | Delete task |
| POST | `/api/v1/tasks/:id/complete` | Mark complete |
| POST | `/api/v1/tasks/:id/reopen` | Reopen task |
| POST | `/api/v1/tasks/:id/schedule` | Schedule to date |
| POST | `/api/v1/tasks/:id/unschedule` | Move to backlog |
| GET | `/api/v1/channels` | List channels |
| GET | `/api/v1/contexts` | List contexts |
| GET | `/api/v1/weekly_objectives` | List weekly objectives |
| GET | `/api/v1/calendar_events` | List calendar events |
| GET | `/api/v1/working_sessions` | List working sessions |
| POST | `/api/v1/timer/start` | Start timer |
| POST | `/api/v1/timer/stop` | Stop timer |
| GET | `/api/v1/timer/current` | Active timer |
| GET | `/api/v1/daily_plans/:date` | Daily plan with stats |
| GET | `/api/v1/search?q=keyword` | Search tasks |

## Install as App (PWA)

Solara works as a Progressive Web App:

- **macOS:** Open in Chrome/Edge > Three dots menu > "Install Solara"
- **iOS:** Open in Safari > Share button > "Add to Home Screen"
- **Android:** Open in Chrome > "Add to Home Screen" prompt

## Project Structure

```
solara/
├── app/
│   ├── controllers/
│   │   ├── api/v1/          # REST API controllers
│   │   ├── dashboard_controller.rb
│   │   ├── tasks_controller.rb
│   │   ├── daily_plans_controller.rb
│   │   └── ...
│   ├── models/              # ActiveRecord models
│   ├── views/
│   │   ├── layouts/         # Main layout, sidebar, top bar, timer
│   │   ├── dashboard/       # Daily view
│   │   ├── tasks/           # Task CRUD + partials
│   │   ├── daily_plans/     # Morning planning + shutdown
│   │   └── ...
│   └── javascript/
│       └── controllers/     # Stimulus controllers (sortable, timer, etc.)
├── config/
├── db/
│   ├── migrate/             # All migrations
│   └── seeds.rb             # Default user + sample data
├── docker-compose.yml       # Production deployment
├── Dockerfile
└── .env.example
```

## Data Model

```
User → Contexts → Channels → Tasks
                              ├── Subtasks (self-referencing)
                              ├── Working Sessions
                              ├── Timer Sessions
                              └── Documents

User → Weekly Objectives ← Tasks
User → Daily Plans
User → Calendar Integrations → Calendar Events
```

## Roadmap

- [x] Task management with channels and contexts
- [x] Daily planning and shutdown rituals
- [x] Calendar timeline view
- [x] Timer with stopwatch and Pomodoro
- [x] Weekly objectives
- [x] REST API
- [x] PWA support
- [ ] Google Calendar OAuth integration
- [ ] MCP server for AI agent access
- [ ] Document hub (rich text docs attached to tasks/channels)
- [ ] Recurring tasks (iCal RRULE)
- [ ] Webhooks for external integrations
- [ ] Email-to-task (Gmail integration)
- [ ] Messaging integration (Slack/Teams)
- [ ] Analytics dashboard

## License

MIT
