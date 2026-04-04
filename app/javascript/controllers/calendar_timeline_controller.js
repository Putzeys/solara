import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollToCurrentHour()
  }

  scrollToCurrentHour() {
    const now = new Date()
    const currentHour = now.getHours()
    const hourElement = this.element.querySelector(`[data-hour="${currentHour}"]`)
    const scrollContainer = this.element.querySelector(".overflow-y-auto")
    if (hourElement && scrollContainer) {
      scrollContainer.scrollTop = hourElement.offsetTop - scrollContainer.offsetHeight / 2
    }
  }
}
