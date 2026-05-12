import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]
  static values = { delay: { type: Number, default: 250 } }

  connect() {
    this.boundHandleFrameLoad = this.handleFrameLoad.bind(this)
    this.resultsFrame?.addEventListener("turbo:frame-load", this.boundHandleFrameLoad)
  }

  scheduleSubmit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, this.delayValue)
  }

  handleFrameLoad() {
    if (!this.hasInputTarget) return

    const currentQuery = this.inputTarget.value.trim()
    const renderedQuery = (this.resultsFrame?.dataset.searchQuery || "").trim()
    if (currentQuery != renderedQuery) {
      this.element.requestSubmit()
    }
  }

  get resultsFrame() {
    return document.getElementById("users_results")
  }

  disconnect() {
    clearTimeout(this.timeout)
    this.resultsFrame?.removeEventListener("turbo:frame-load", this.boundHandleFrameLoad)
  }
}
