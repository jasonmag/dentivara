import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "content"]

  open(event) {
    event.preventDefault()

    const url = event.currentTarget.dataset.modalUrl
    if (!url) return

    this.showLoadingState()
    if (!this.dialogTarget.open) this.dialogTarget.showModal()

    fetch(url, { headers: { Accept: "text/html" } })
      .then((response) => {
        if (!response.ok) throw new Error("Failed to load appointment details")

        return response.text()
      })
      .then((html) => {
        this.contentTarget.innerHTML = html
      })
      .catch(() => {
        this.contentTarget.innerHTML = `
          <div class="rounded-2xl border border-red-200 bg-red-50 p-4 text-sm text-red-900">
            Unable to load appointment details right now.
          </div>
        `
      })
  }

  close() {
    if (this.hasContentTarget) this.contentTarget.innerHTML = ""
    this.dialogTarget.close()
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  showLoadingState() {
    this.contentTarget.innerHTML = `
      <div class="flex min-h-64 items-center justify-center rounded-2xl border border-stone-100 bg-white p-8 text-stone-500">
        Loading appointment details...
      </div>
    `
  }
}
