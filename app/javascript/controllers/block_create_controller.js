import { Controller } from "@hotwired/stimulus"

// Tap an empty timeline hour -> pick a task -> create a working session block.
// The task list is read live from the DOM so tasks just added via Turbo are
// immediately pickable (no full page reload needed).
export default class extends Controller {
  static targets = ["modal", "label", "list"]
  static values = { date: String, action: String }

  openAt(event) {
    if (event.target.closest("[data-event-title], [data-block]")) return // existing item tapped
    this.hour = parseInt(event.currentTarget.dataset.hour, 10)
    this.labelTarget.textContent = `${String(this.hour).padStart(2, "0")}:00 – ${String(this.hour + 1).padStart(2, "0")}:00`
    this.renderTasks()
    this.modalTarget.classList.remove("hidden")
  }

  renderTasks() {
    const rows = document.querySelectorAll("#tasks_container [data-task-id]")
    const tasks = []
    rows.forEach((row) => {
      const link = row.querySelector("a[href*='/tasks/']")
      if (!link) return
      if (link.className.includes("line-through")) return // skip done tasks
      tasks.push({ id: row.dataset.taskId, title: link.textContent.trim() })
    })

    if (tasks.length === 0) {
      this.listTarget.innerHTML = `<p class="text-xs text-gray-400 text-center py-6">No open tasks for today.</p>`
      return
    }

    this.listTarget.innerHTML = tasks
      .map(
        (t) => `<button type="button" data-action="click->block-create#pick" data-task-id="${t.id}"
          class="w-full text-left px-3 py-3 rounded-xl hover:bg-indigo-50 active:bg-indigo-100 text-sm text-gray-700 transition-colors">${this.escape(t.title)}</button>`
      )
      .join("")
  }

  escape(s) {
    const d = document.createElement("div")
    d.textContent = s
    return d.innerHTML
  }

  close() {
    this.modalTarget.classList.add("hidden")
  }

  stop(event) {
    event.stopPropagation()
  }

  pick(event) {
    const taskId = event.currentTarget.dataset.taskId
    const pad = (n) => String(n).padStart(2, "0")
    const start = `${this.dateValue}T${pad(this.hour)}:00:00`
    const end = `${this.dateValue}T${pad(this.hour + 1)}:00:00`
    const csrf = document.querySelector("meta[name=csrf-token]").content

    // Plain form POST so the controller's redirect_back reloads the timeline.
    const form = document.createElement("form")
    form.method = "post"
    form.action = this.actionValue
    form.innerHTML = `
      <input type="hidden" name="authenticity_token">
      <input type="hidden" name="working_session[task_id]">
      <input type="hidden" name="working_session[starts_at]">
      <input type="hidden" name="working_session[ends_at]">
    `
    form.querySelector("[name=authenticity_token]").value = csrf
    form.querySelector("[name='working_session[task_id]']").value = taskId
    form.querySelector("[name='working_session[starts_at]']").value = start
    form.querySelector("[name='working_session[ends_at]']").value = end
    document.body.appendChild(form)
    form.submit()
  }
}
