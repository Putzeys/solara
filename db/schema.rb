# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_04_01_180722) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "calendar_events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "calendar_integration_id", null: false
    t.string "google_event_id", null: false
    t.string "google_calendar_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "location"
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.boolean "all_day", default: false
    t.string "status", default: "confirmed"
    t.jsonb "attendees", default: []
    t.string "html_link"
    t.boolean "recurring", default: false
    t.jsonb "raw_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_integration_id"], name: "index_calendar_events_on_calendar_integration_id"
    t.index ["google_event_id", "google_calendar_id"], name: "idx_cal_events_google_unique", unique: true
    t.index ["user_id", "starts_at", "ends_at"], name: "index_calendar_events_on_user_id_and_starts_at_and_ends_at"
    t.index ["user_id"], name: "index_calendar_events_on_user_id"
  end

  create_table "calendar_integrations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "provider", default: "google", null: false
    t.text "access_token", null: false
    t.text "refresh_token", null: false
    t.datetime "token_expires_at"
    t.jsonb "calendar_ids", default: []
    t.string "sync_token"
    t.datetime "last_synced_at"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "provider"], name: "index_calendar_integrations_on_user_id_and_provider", unique: true
    t.index ["user_id"], name: "index_calendar_integrations_on_user_id"
  end

  create_table "channels", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "context_id"
    t.string "name", null: false
    t.string "color", default: "#8b5cf6", null: false
    t.string "icon"
    t.integer "position", default: 0, null: false
    t.boolean "archived", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["context_id"], name: "index_channels_on_context_id"
    t.index ["user_id", "archived"], name: "index_channels_on_user_id_and_archived"
    t.index ["user_id", "context_id", "position"], name: "index_channels_on_user_id_and_context_id_and_position"
    t.index ["user_id"], name: "index_channels_on_user_id"
  end

  create_table "contexts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "color", default: "#6366f1", null: false
    t.string "icon"
    t.integer "position", default: 0, null: false
    t.boolean "archived", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "archived"], name: "index_contexts_on_user_id_and_archived"
    t.index ["user_id", "position"], name: "index_contexts_on_user_id_and_position"
    t.index ["user_id"], name: "index_contexts_on_user_id"
  end

  create_table "daily_plans", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "plan_date", null: false
    t.boolean "morning_completed", default: false
    t.boolean "shutdown_completed", default: false
    t.datetime "morning_completed_at"
    t.datetime "shutdown_completed_at"
    t.integer "total_planned_min", default: 0
    t.integer "total_actual_min", default: 0
    t.integer "tasks_completed", default: 0
    t.integer "tasks_rolled_over", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "plan_date"], name: "index_daily_plans_on_user_id_and_plan_date", unique: true
    t.index ["user_id"], name: "index_daily_plans_on_user_id"
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "documentable_type", null: false
    t.bigint "documentable_id", null: false
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["documentable_type", "documentable_id"], name: "index_documents_on_documentable_type_and_documentable_id"
    t.index ["user_id"], name: "index_documents_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "channel_id"
    t.bigint "weekly_objective_id"
    t.bigint "parent_task_id"
    t.string "title", null: false
    t.string "status", default: "todo", null: false
    t.integer "priority", default: 0
    t.date "scheduled_date"
    t.datetime "completed_at"
    t.integer "planned_minutes"
    t.integer "actual_minutes", default: 0
    t.integer "position", default: 0, null: false
    t.datetime "time_slot_start"
    t.datetime "time_slot_end"
    t.string "recurrence_rule"
    t.bigint "recurrence_parent_id"
    t.date "due_date"
    t.date "snoozed_until"
    t.string "source", default: "manual"
    t.string "external_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_tasks_on_channel_id"
    t.index ["parent_task_id"], name: "index_tasks_on_parent_task_id"
    t.index ["recurrence_parent_id"], name: "index_tasks_on_recurrence_parent_id"
    t.index ["user_id", "channel_id"], name: "index_tasks_on_user_id_and_channel_id"
    t.index ["user_id", "scheduled_date", "position"], name: "index_tasks_on_user_id_and_scheduled_date_and_position"
    t.index ["user_id", "status"], name: "index_tasks_on_user_id_and_status"
    t.index ["user_id"], name: "index_tasks_on_user_id"
    t.index ["user_id"], name: "index_tasks_on_user_id_backlog", where: "(scheduled_date IS NULL)"
    t.index ["weekly_objective_id"], name: "index_tasks_on_weekly_objective_id"
  end

  create_table "timer_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "task_id", null: false
    t.datetime "started_at", null: false
    t.datetime "ended_at"
    t.integer "duration_seconds"
    t.string "timer_type", default: "stopwatch"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_timer_sessions_on_task_id"
    t.index ["user_id", "started_at"], name: "index_timer_sessions_on_user_id_and_started_at"
    t.index ["user_id"], name: "index_timer_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "timezone", default: "America/Sao_Paulo", null: false
    t.integer "daily_hour_target", default: 480
    t.integer "week_start_day", default: 1
    t.integer "pomodoro_work_min", default: 25
    t.integer "pomodoro_break_min", default: 5
    t.string "api_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "weekly_objectives", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.date "week_start_date", null: false
    t.string "status", default: "active"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "week_start_date"], name: "index_weekly_objectives_on_user_id_and_week_start_date"
    t.index ["user_id"], name: "index_weekly_objectives_on_user_id"
  end

  create_table "working_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "task_id", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.string "google_event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id"], name: "index_working_sessions_on_task_id"
    t.index ["user_id", "starts_at", "ends_at"], name: "index_working_sessions_on_user_id_and_starts_at_and_ends_at"
    t.index ["user_id"], name: "index_working_sessions_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "calendar_events", "calendar_integrations"
  add_foreign_key "calendar_events", "users"
  add_foreign_key "calendar_integrations", "users"
  add_foreign_key "channels", "contexts"
  add_foreign_key "channels", "users"
  add_foreign_key "contexts", "users"
  add_foreign_key "daily_plans", "users"
  add_foreign_key "documents", "users"
  add_foreign_key "tasks", "channels"
  add_foreign_key "tasks", "tasks", column: "parent_task_id"
  add_foreign_key "tasks", "tasks", column: "recurrence_parent_id"
  add_foreign_key "tasks", "users"
  add_foreign_key "tasks", "weekly_objectives"
  add_foreign_key "timer_sessions", "tasks"
  add_foreign_key "timer_sessions", "users"
  add_foreign_key "weekly_objectives", "users"
  add_foreign_key "working_sessions", "tasks"
  add_foreign_key "working_sessions", "users"
end
