import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "input"]

  toggle() {
    this.formTarget.classList.toggle("hidden")
    if (!this.formTarget.classList.contains("hidden")) {
      this.inputTarget.focus()
    }
  }

  afterSubmit(event) {
    if (event.detail.success) {
      this.inputTarget.value = ""
      this.inputTarget.focus()
    }
  }
}
