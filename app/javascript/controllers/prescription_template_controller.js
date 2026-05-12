import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "body"]
  static values = { endpoint: String }

  async updateBody() {
    const templateId = this.selectTarget.value
    if (!templateId) return

    const url = `${this.endpointValue}?document_template_id=${encodeURIComponent(templateId)}`
    const response = await fetch(url, { headers: { Accept: "application/json" } })
    if (!response.ok) return

    const data = await response.json()
    if (typeof data.body === "string") this.bodyTarget.value = data.body
  }
}
