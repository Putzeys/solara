import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => {
      this.element.style.transition = "opacity 0.3s, transform 0.3s"
      this.element.style.opacity = "0"
      this.element.style.transform = "translateY(-8px)"
      setTimeout(() => this.element.remove(), 300)
    }, 4000)
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }
}
