import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "popup", "filters", "title", "time", "calendar", "colorDot",
    "location", "locationRow", "attendees", "attendeesRow",
    "description", "descriptionRow", "link", "linkRow",
    "account", "accountRow"
  ]

  show(event) {
    const el = event.currentTarget
    this.titleTarget.textContent = el.dataset.eventTitle
    this.timeTarget.innerHTML = el.dataset.eventTime
    this.calendarTarget.textContent = el.dataset.eventCalendar
    this.colorDotTarget.style.backgroundColor = el.dataset.eventCalendarColor

    this.setOptional(this.locationTarget, this.locationRowTarget, el.dataset.eventLocation)
    this.setOptional(this.attendeesTarget, this.attendeesRowTarget, el.dataset.eventAttendees)
    this.setOptional(this.descriptionTarget, this.descriptionRowTarget, el.dataset.eventDescription)

    if (el.dataset.eventAccount) {
      this.accountTarget.textContent = el.dataset.eventAccount
      this.accountRowTarget.classList.remove("hidden")
    } else {
      this.accountRowTarget.classList.add("hidden")
    }

    if (el.dataset.eventLink) {
      this.linkTarget.href = el.dataset.eventLink
      this.linkRowTarget.classList.remove("hidden")
    } else {
      this.linkRowTarget.classList.add("hidden")
    }

    this.popupTarget.classList.remove("hidden")
  }

  hide() {
    this.popupTarget.classList.add("hidden")
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  toggleFilters() {
    this.filtersTarget.classList.toggle("hidden")
  }

  setOptional(contentTarget, rowTarget, value) {
    if (value && value.trim()) {
      contentTarget.textContent = value
      rowTarget.classList.remove("hidden")
    } else {
      rowTarget.classList.add("hidden")
    }
  }
}
