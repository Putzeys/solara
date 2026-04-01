user = User.find_or_create_by!(email: "admin@solara.local") do |u|
  u.password = "password"
  u.timezone = "America/Sao_Paulo"
  u.daily_hour_target = 480
end

puts "User: #{user.email} (API token: #{user.api_token})"

# Contexts
work = user.contexts.find_or_create_by!(name: "Work") do |c|
  c.color = "#6366f1"
  c.position = 0
end

personal = user.contexts.find_or_create_by!(name: "Personal") do |c|
  c.color = "#10b981"
  c.position = 1
end

# Channels
channels_data = [
  { name: "#product", context: work, color: "#8b5cf6" },
  { name: "#engineering", context: work, color: "#3b82f6" },
  { name: "#meetings", context: work, color: "#f59e0b" },
  { name: "#health", context: personal, color: "#ef4444" },
  { name: "#finance", context: personal, color: "#22c55e" },
  { name: "#learning", context: personal, color: "#06b6d4" }
]

channels = {}
channels_data.each_with_index do |data, i|
  channels[data[:name]] = user.channels.find_or_create_by!(name: data[:name]) do |c|
    c.context = data[:context]
    c.color = data[:color]
    c.position = i
  end
end

# Sample tasks for today
today = Date.current
[
  { title: "Review pull requests", channel: channels["#engineering"], planned_minutes: 30, priority: 2 },
  { title: "Weekly team sync", channel: channels["#meetings"], planned_minutes: 60, priority: 1 },
  { title: "Plan sprint backlog", channel: channels["#product"], planned_minutes: 45, priority: 2 },
  { title: "Exercise", channel: channels["#health"], planned_minutes: 45, priority: 1 },
].each_with_index do |data, i|
  user.tasks.find_or_create_by!(title: data[:title], scheduled_date: today) do |t|
    t.channel = data[:channel]
    t.planned_minutes = data[:planned_minutes]
    t.priority = data[:priority]
    t.position = i
  end
end

# Sample backlog tasks
[
  { title: "Research new monitoring tools", channel: channels["#engineering"] },
  { title: "Write blog post about architecture", channel: channels["#engineering"] },
  { title: "Set up budget tracker", channel: channels["#finance"] },
  { title: "Read 'Designing Data-Intensive Applications'", channel: channels["#learning"] },
].each_with_index do |data, i|
  user.tasks.find_or_create_by!(title: data[:title], scheduled_date: nil) do |t|
    t.channel = data[:channel]
    t.position = i
  end
end

# Weekly objective
user.weekly_objectives.find_or_create_by!(
  title: "Ship v2 auth module",
  week_start_date: today.beginning_of_week(:monday)
) do |o|
  o.status = "active"
  o.position = 0
end

puts "Seed complete!"
