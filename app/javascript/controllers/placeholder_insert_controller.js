import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "feedback"]

  connect() {
    this.activeField = this.fieldTargets[0] || null
  }

  activate(event) {
    this.activeField = event.currentTarget
  }

  insert(event) {
    const token = event.currentTarget.dataset.token
    if (!token) return

    const field = this.activeField || this.fieldTargets[0]
    if (!field) return

    const start = field.selectionStart || 0
    const end = field.selectionEnd || 0
    const value = field.value || ""

    field.value = `${value.slice(0, start)}${token}${value.slice(end)}`
    const nextPos = start + token.length
    field.focus()
    field.setSelectionRange(nextPos, nextPos)
    field.dispatchEvent(new Event("input", { bubbles: true }))
    this.showFeedback(token)
  }

  showFeedback(token) {
    if (!this.hasFeedbackTarget) return

    this.feedbackTarget.textContent = `Inserted ${token}`
    this.feedbackTarget.classList.remove("opacity-0")
    this.feedbackTarget.classList.add("opacity-100")

    clearTimeout(this.feedbackTimeout)
    this.feedbackTimeout = setTimeout(() => {
      this.feedbackTarget.classList.remove("opacity-100")
      this.feedbackTarget.classList.add("opacity-0")
    }, 1200)
  }
}
