import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      ghostClass: "bg-indigo-50",
      handle: "[data-task-id]",
      onEnd: this.onEnd.bind(this)
    })
  }

  disconnect() {
    if (this.sortable) this.sortable.destroy()
  }

  onEnd(event) {
    if (event.oldIndex === event.newIndex) return

    const taskIds = Array.from(this.element.children)
      .map(el => el.querySelector("[data-task-id]"))
      .filter(el => el)
      .map(el => el.dataset.taskId)

    const token = document.querySelector('meta[name="csrf-token"]')?.content

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
        "Accept": "application/json"
      },
      body: JSON.stringify({ task_ids: taskIds })
    })
  }
}
