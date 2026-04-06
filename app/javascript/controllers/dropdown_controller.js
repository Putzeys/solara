import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }

  hide() {
    this.menuTarget.classList.add("hidden")
  }

  connect() {
    this.hideHandler = () => this.hide()
    document.addEventListener("click", this.hideHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.hideHandler)
  }
}
