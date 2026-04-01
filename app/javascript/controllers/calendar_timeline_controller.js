import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollToCurrentHour()
  }

  scrollToCurrentHour() {
    const now = new Date()
    const currentHour = now.getHours()
    const hourElement = this.element.querySelector(`[data-hour="${currentHour}"]`)
    if (hourElement) {
      hourElement.scrollIntoView({ behavior: "smooth", block: "center" })
    }
  }
}
