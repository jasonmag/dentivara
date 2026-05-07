import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "image", "trigger", "counter"]

  connect() {
    this.currentIndex = 0
    this.boundKeydown = this.handleKeydown.bind(this)
  }

  open(event) {
    const src = event.currentTarget.dataset.fullImageUrl
    if (!src) return

    this.currentIndex = Number(event.currentTarget.dataset.previewIndex || 0)
    this.showAt(this.currentIndex)
    this.dialogTarget.showModal()
    window.addEventListener("keydown", this.boundKeydown)
  }

  close() {
    this.dialogTarget.close()
    this.imageTarget.src = ""
    window.removeEventListener("keydown", this.boundKeydown)
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  previous() {
    if (!this.triggerTargets.length) return
    this.currentIndex = (this.currentIndex - 1 + this.triggerTargets.length) % this.triggerTargets.length
    this.showAt(this.currentIndex)
  }

  next() {
    if (!this.triggerTargets.length) return
    this.currentIndex = (this.currentIndex + 1) % this.triggerTargets.length
    this.showAt(this.currentIndex)
  }

  handleKeydown(event) {
    if (!this.dialogTarget.open) return

    if (event.key == "ArrowLeft") {
      this.previous()
      event.preventDefault()
    } else if (event.key == "ArrowRight") {
      this.next()
      event.preventDefault()
    } else if (event.key == "Escape") {
      this.close()
      event.preventDefault()
    }
  }

  showAt(index) {
    const trigger = this.triggerTargets[index]
    if (!trigger) return
    this.imageTarget.src = trigger.dataset.fullImageUrl
    if (this.hasCounterTarget) this.counterTarget.textContent = `${index + 1} / ${this.triggerTargets.length}`
  }
}
