# Changelog

All notable changes to Solara will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.1.0] - 2026-04-01

### Added

#### Core Application
- Rails 8.0 application with PostgreSQL, Hotwire (Turbo + Stimulus), and Tailwind CSS v4
- Devise authentication with single-user setup (multi-user ready)
- User settings: timezone, daily hour target, Pomodoro config, API token

#### Task Management
- Full task CRUD with Turbo Frame responses (no page reloads)
- Task properties: title, rich text notes (ActionText), planned/actual time, priority (0-3), due date
- Task statuses: todo, in_progress, done, cancelled
- Subtasks via self-referencing (parent_task_id)
- Quick-add input on dashboard and backlog views
- Complete/reopen tasks with animated checkbox
- Schedule tasks to dates or move to backlog
- Drag-and-drop reordering via SortableJS

#### Organization
- **Channels** — Categorize tasks by project (e.g. #product, #engineering, #health)
- **Contexts** — Group channels into contexts (e.g. Work, Personal)
- Channel management UI with color picker
- Sidebar navigation with channels grouped by context

#### Planning
- **Morning Planning** — Guided ritual: review yesterday's tasks, roll over incomplete, pull from backlog
- **Daily Shutdown** — Review completed/remaining tasks, time stats, roll over or move to backlog
- **Weekly Objectives** — Create/edit high-level weekly goals, visible in sidebar
- **Workload indicator** — Top bar shows planned hours vs daily target with color-coded warnings
- Task rollover to next day (individual or bulk)

#### Calendar & Time
- Calendar timeline view (7:00-22:00) alongside task list
- Working sessions model (timeboxing tasks to calendar slots)
- Calendar events model (Google Calendar cache, ready for Phase 2 integration)
- Timer sessions with stopwatch mode
- Persistent timer bar at bottom of screen with elapsed time display

#### UI/UX
- Responsive layout: sidebar + split view (tasks | timeline) on desktop, stacked on mobile
- Dark gradient sidebar with active state indicators
- Glassmorphism top bar with backdrop blur
- Card-based design with rounded corners, subtle shadows, translucent borders
- Inter font via Google Fonts
- Animated flash messages with auto-dismiss (4s)
- Mobile hamburger menu with slide-in drawer and overlay
- Color-coded priority badges (HIGH/MED/LOW)
- Channel color dots in sidebar and task badges
- Custom thin scrollbar styling
- Smooth transitions (150ms) on all interactive elements

#### PWA (Progressive Web App)
- Web App Manifest (standalone mode, theme color, icons)
- Service Worker with network-first caching strategy
- iOS meta tags (apple-mobile-web-app-capable, status bar style)
- Installable on macOS (Chrome/Edge), iOS (Safari), and Android

#### REST API
- Full API namespace at `/api/v1/` with Bearer token authentication
- Endpoints for: tasks (CRUD + complete/reopen/schedule), channels, contexts, weekly objectives, calendar events, working sessions, timer (start/stop/current), daily plans, search
- JSON responses with `{ data: ... }` envelope

#### Data Model
- 11 database tables: users, contexts, channels, tasks, weekly_objectives, daily_plans, working_sessions, timer_sessions, calendar_integrations, calendar_events, documents
- Partial index for backlog queries (tasks where scheduled_date IS NULL)
- Self-referencing tasks for subtasks and recurrence instances
- ActiveRecord Encryption ready for OAuth tokens
- Polymorphic documents (attachable to tasks or channels)
- ActionText and ActiveStorage installed

#### Infrastructure
- Docker Compose setup (PostgreSQL + Rails + Solid Queue)
- Dockerfile with multi-stage build (Ruby 3.2 slim)
- Seed data with default user, contexts, channels, sample tasks, and weekly objective
- Memory budget ~2.5GB (fits 8GB server)

### Not Yet Implemented (Planned)
- Google Calendar OAuth2 integration (model ready, OAuth flow placeholder)
- MCP server for AI agent access
- Recurring tasks engine (ice_cube gem included)
- Document hub UI
- Focus mode full-screen view
- Pomodoro timer mode
- Webhooks
- Analytics dashboard
