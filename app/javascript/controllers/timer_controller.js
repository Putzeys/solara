import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]
  static values = { startedAt: String }

  connect() {
    this.startTime = new Date(this.startedAtValue)
    this.tick()
    this.interval = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval)
  }

  tick() {
    const elapsed = Math.floor((Date.now() - this.startTime.getTime()) / 1000)
    const hours = Math.floor(elapsed / 3600)
    const minutes = Math.floor((elapsed % 3600) / 60)
    const seconds = elapsed % 60

    this.displayTarget.textContent =
      `${String(hours).padStart(2, "0")}:${String(minutes).padStart(2, "0")}:${String(seconds).padStart(2, "0")}`
  }
}
