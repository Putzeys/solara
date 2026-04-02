import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "channelId", "channelBadge", "dropdown"]

  connect() {
    this.hashMode = false
    this.hashStart = -1
  }

  onInput() {
    const value = this.inputTarget.value
    const cursorPos = this.inputTarget.selectionStart
    const textBeforeCursor = value.substring(0, cursorPos)
    const hashIndex = textBeforeCursor.lastIndexOf("#")

    if (hashIndex >= 0 && (hashIndex === 0 || value[hashIndex - 1] === " ")) {
      this.hashMode = true
      this.hashStart = hashIndex
      const query = textBeforeCursor.substring(hashIndex + 1).toLowerCase()
      this.filterChannels(query)
      this.showDropdown()
    } else {
      this.hideDropdown()
      this.hashMode = false
    }
  }

  onKeydown(event) {
    if (event.key === "Escape" && this.hashMode) {
      this.hideDropdown()
      this.hashMode = false
      event.preventDefault()
    }
  }

  filterChannels(query) {
    const options = this.dropdownTarget.querySelectorAll(".channel-option")
    options.forEach(option => {
      const name = option.dataset.channelName.toLowerCase()
      option.style.display = name.includes(query) ? "" : "none"
    })
  }

  selectChannel(event) {
    const button = event.currentTarget
    const channelId = button.dataset.channelId
    const channelName = button.dataset.channelName
    const channelColor = button.dataset.channelColor

    // Set hidden field
    this.channelIdTarget.value = channelId

    // Remove #text from title
    const value = this.inputTarget.value
    const before = value.substring(0, this.hashStart)
    const afterHash = value.substring(this.hashStart)
    const spaceAfter = afterHash.indexOf(" ", 1)
    const after = spaceAfter >= 0 ? afterHash.substring(spaceAfter) : ""
    this.inputTarget.value = (before + after).trim()

    // Show badge
    this.channelBadgeTarget.textContent = channelName
    this.channelBadgeTarget.style.backgroundColor = channelColor + "15"
    this.channelBadgeTarget.style.color = channelColor
    this.channelBadgeTarget.classList.remove("hidden")

    this.hideDropdown()
    this.hashMode = false
    this.inputTarget.focus()
  }

  showDropdown() {
    this.dropdownTarget.classList.remove("hidden")
  }

  hideDropdown() {
    this.dropdownTarget.classList.add("hidden")
  }

  reset() {
    this.inputTarget.value = ""
    this.channelIdTarget.value = ""
    this.channelBadgeTarget.classList.add("hidden")
    this.hideDropdown()
    this.hashMode = false
    this.inputTarget.focus()
  }
}
