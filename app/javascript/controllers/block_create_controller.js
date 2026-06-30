import { Controller } from "@hotwired/stimulus"

// Tap an empty timeline hour -> pick a task -> create a working session block.
export default class extends Controller {
  static targets = ["modal", "label"]
  static values = { date: String }

  openAt(event) {
    // Ignore taps that land on an existing event or working-session block.
    if (event.target.closest("[data-event-title], [data-block]")) return
    this.hour = parseInt(event.currentTarget.dataset.hour, 10)
    this.labelTarget.textContent = `${String(this.hour).padStart(2, "0")}:00 – ${String(this.hour + 1).padStart(2, "0")}:00`
    this.modalTarget.classList.remove("hidden")
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
    form.action = "/working_sessions"
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
