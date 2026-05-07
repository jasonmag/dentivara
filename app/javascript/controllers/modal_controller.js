import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "printArea"]

  open() {
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  closeOnBackdrop(event) {
    if (event.target === this.dialogTarget) this.close()
  }

  print() {
    if (!this.hasPrintAreaTarget) return

    const printWindow = window.open("", "_blank", "width=900,height=700")
    if (!printWindow) return

    const content = this.printAreaTarget.innerHTML
    printWindow.document.write(`
      <html>
        <head>
          <title></title>
          <base href="${window.location.origin}">
          <style>
            body { font-family: "Times New Roman", serif; margin: 24px; color: #111; }
            .prescription-sheet { border: 1px solid #d1d5db; border-radius: 10px; overflow: hidden; background: #fff; }
            .prescription-header { display: flex; align-items: flex-start; justify-content: space-between; gap: 18px; padding: 28px 32px 22px; border-bottom: 2px solid #111; }
            .clinic-name { margin: 0; font-family: Arial, sans-serif; font-size: 28px; font-weight: 700; color: #111; }
            .clinic-details { margin-top: 6px; white-space: pre-line; font-family: Arial, sans-serif; font-size: 13px; line-height: 1.55; color: #333; }
            .prescription-logo { width: 96px; height: 80px; display: flex; align-items: center; justify-content: center; padding: 8px; }
            .prescription-logo img { max-width: 100%; max-height: 100%; object-fit: contain; }
            .prescription-info { display: grid; grid-template-columns: 1fr 1fr; gap: 14px 22px; padding: 22px 32px; border-bottom: 1px solid #d1d5db; font-family: Arial, sans-serif; font-size: 13px; }
            .prescription-field { display: flex; align-items: flex-end; gap: 8px; }
            .prescription-field span:first-child { flex-shrink: 0; font-weight: 700; color: #111; }
            .field-line { min-height: 22px; flex: 1; border-bottom: 1px solid #6b7280; padding: 0 8px; color: #111; }
            .prescription-body { position: relative; min-height: 360px; padding: 28px 32px; }
            .rx-watermark { position: absolute; left: 34px; top: 30px; color: #f3f4f6; font-size: 120px; font-weight: 700; line-height: 1; pointer-events: none; }
            .prescription-content { position: relative; z-index: 1; margin: 0 0 0 92px; white-space: pre-wrap; font-size: 15px; line-height: 1.65; color: #111; }
            .prescription-signature { display: flex; justify-content: flex-end; padding: 0 32px 24px; }
            .prescription-signature > div { width: 260px; text-align: center; }
            .signature-image { max-height: 64px; max-width: 220px; object-fit: contain; display: block; margin: 0 auto; }
            .prescription-signature p { margin: 0; }
            .prescription-signature p:first-of-type { border-top: 1px solid #374151; padding-top: 5px; font-family: Arial, sans-serif; font-size: 13px; font-weight: 700; color: #111; }
            .prescription-signature p:last-of-type { margin-top: 2px; font-family: Arial, sans-serif; font-size: 11px; color: #333; }
            .prescription-footer { display: grid; grid-template-columns: 1fr 1.4fr 1fr; gap: 14px; padding: 16px 32px; border-top: 1px solid #d1d5db; color: #111; font-family: Arial, sans-serif; font-size: 12px; }
            .prescription-footer p { margin: 0; }
            .rx-sheet { border: 1px solid #d1d5db; border-radius: 10px; overflow: hidden; }
            .rx-header { padding: 18px 20px; border-bottom: 2px solid #111827; }
            .rx-title { font-size: 30px; margin: 0; letter-spacing: 0.08em; }
            .rx-subtitle { margin: 4px 0 0; font-family: Arial, sans-serif; font-size: 12px; color: #4b5563; text-transform: uppercase; letter-spacing: 0.08em; }
            .rx-meta { display: grid; grid-template-columns: 1fr 1fr; gap: 8px 16px; padding: 14px 20px; border-bottom: 1px solid #e5e7eb; font-family: Arial, sans-serif; font-size: 13px; }
            .rx-body { padding: 18px 20px 26px; min-height: 320px; }
            .rx-symbol { font-size: 44px; line-height: 1; margin-bottom: 8px; }
            .rx-content { white-space: pre-wrap; font-size: 15px; line-height: 1.6; margin: 0; }
            .rx-footer { padding: 14px 20px 20px; border-top: 1px solid #e5e7eb; }
            .rx-sign-line { margin-top: 20px; border-top: 1px solid #374151; width: 280px; padding-top: 6px; font-family: Arial, sans-serif; font-size: 12px; color: #374151; }
            .rx-sign-image { max-height: 80px; max-width: 260px; display: block; margin-top: 10px; object-fit: contain; }
            @page { margin: 0; }
            @media print {
              body { margin: 0; padding: 16mm; }
              .rx-sheet, .prescription-sheet { border: 0; border-radius: 0; }
              .prescription-sheet { min-height: calc(100vh - 32mm); }
            }
          </style>
        </head>
        <body>${content}</body>
      </html>
    `)
    printWindow.document.close()
    this.printAfterImagesLoad(printWindow)
  }

  printAfterImagesLoad(printWindow) {
    const images = Array.from(printWindow.document.images)
    const imagePromises = images.map((image) => {
      if (image.complete) return Promise.resolve()

      return new Promise((resolve) => {
        image.addEventListener("load", resolve, { once: true })
        image.addEventListener("error", resolve, { once: true })
      })
    })

    Promise.all(imagePromises).then(() => {
      printWindow.focus()
      printWindow.print()
      printWindow.close()
    })
  }
}
