import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { activeTimer: String }

  connect() {
    this.drawNowLine()
    this.drawActiveTimer()
    this.scrollToCurrentHour()
    this.timer = setInterval(() => {
      this.drawNowLine()
      this.drawActiveTimer()
    }, 60000)
  }

  disconnect() {
    if (this.timer) clearInterval(this.timer)
  }

  scrollToCurrentHour() {
    const nowLine = this.element.querySelector("[data-now-line]")
    const scrollContainer = this.element.querySelector(".overflow-y-auto")
    if (nowLine && scrollContainer) {
      scrollContainer.scrollTop = nowLine.offsetTop - scrollContainer.offsetHeight / 2
    }
  }

  drawNowLine() {
    const now = new Date()
    const hour = now.getHours()
    const minutes = now.getMinutes()

    const existing = this.element.querySelector("[data-now-line]")
    if (existing) existing.remove()

    const hourEl = this.element.querySelector(`[data-hour="${hour}"]`)
    if (!hourEl) return

    const nextHourEl = this.element.querySelector(`[data-hour="${hour + 1}"]`)
    const slotHeight = nextHourEl
      ? nextHourEl.offsetTop - hourEl.offsetTop
      : hourEl.offsetHeight

    const offset = (minutes / 60) * slotHeight

    const line = document.createElement("div")
    line.setAttribute("data-now-line", "")
    line.className = "absolute left-0 right-0 flex items-center pointer-events-none z-10"
    line.style.top = `${hourEl.offsetTop + offset}px`
    line.innerHTML = `
      <div class="w-2 h-2 rounded-full bg-red-500 -ml-1 shrink-0"></div>
      <div class="flex-1 h-[2px] bg-red-500"></div>
    `

    const container = hourEl.parentElement
    container.appendChild(line)
  }

  drawActiveTimer() {
    const existing = this.element.querySelector("[data-active-timer]")
    if (existing) existing.remove()

    if (!this.hasActiveTimerValue || !this.activeTimerValue) return

    const timerData = JSON.parse(this.activeTimerValue)
    const startedAt = new Date(timerData.started_at)
    const now = new Date()
    const startHour = startedAt.getHours()
    const startMinutes = startedAt.getMinutes()
    const elapsedMin = Math.floor((now - startedAt) / 60000)

    const hourEl = this.element.querySelector(`[data-hour="${startHour}"]`)
    if (!hourEl) return

    const nextHourEl = this.element.querySelector(`[data-hour="${startHour + 1}"]`)
    const slotHeight = nextHourEl
      ? nextHourEl.offsetTop - hourEl.offsetTop
      : hourEl.offsetHeight

    const topOffset = (startMinutes / 60) * slotHeight
    const blockHeight = Math.max((elapsedMin / 60) * slotHeight, 24)

    const block = document.createElement("div")
    block.setAttribute("data-active-timer", "")
    block.className = "absolute left-12 right-3 z-[5]"
    block.style.top = `${hourEl.offsetTop + topOffset}px`
    block.style.minHeight = `${blockHeight}px`
    block.innerHTML = `
      <div class="text-xs bg-emerald-50 text-emerald-700 rounded-lg px-3 py-2 border-l-[3px] border-emerald-500 shadow-sm h-full" style="animation: pulse-dot 2s ease-in-out infinite">
        <span class="font-medium">${timerData.task_title}</span>
        <span class="text-emerald-400 ml-1.5">${startedAt.getHours()}:${String(startedAt.getMinutes()).padStart(2, '0')} &ndash; now (${elapsedMin}m)</span>
      </div>
    `

    const container = hourEl.parentElement
    container.appendChild(block)
  }
}
