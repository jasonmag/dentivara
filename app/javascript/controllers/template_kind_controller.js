import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["kind", "signatureFields"]

  connect() {
    this.toggle()
  }

  toggle() {
    const isPrescription = this.kindTarget.value === "prescription"
    this.signatureFieldsTarget.classList.toggle("hidden", isPrescription)
  }
}
