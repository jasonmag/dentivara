import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas", "hidden", "placeholder"]

  connect() {
    this.ctx = this.canvasTarget.getContext("2d")
    this.isDrawing = false
    this.hasSignature = false
    this.setupCanvas()
    this.bindEvents()
  }

  disconnect() {
    this.unbindEvents()
  }

  clear() {
    this.ctx.clearRect(0, 0, this.canvasTarget.width, this.canvasTarget.height)
    this.hiddenTarget.value = ""
    this.hasSignature = false
    if (this.hasPlaceholderTarget) this.placeholderTarget.classList.remove("hidden")
  }

  beginDraw(event) {
    this.isDrawing = true
    const { x, y } = this.pointerPosition(event)
    this.lastX = x
    this.lastY = y
    event.preventDefault()
  }

  draw(event) {
    if (!this.isDrawing) return

    const { x, y } = this.pointerPosition(event)
    this.ctx.save()
    this.ctx.strokeStyle = "#111827"
    this.ctx.lineWidth = 2
    this.ctx.lineCap = "round"
    this.ctx.lineJoin = "round"
    this.ctx.beginPath()
    this.ctx.moveTo(this.lastX, this.lastY)
    this.ctx.lineTo(x, y)
    this.ctx.stroke()
    this.ctx.restore()

    this.lastX = x
    this.lastY = y
    this.hasSignature = true
    this.hiddenTarget.value = this.canvasTarget.toDataURL("image/png")
    if (this.hasPlaceholderTarget) this.placeholderTarget.classList.add("hidden")
    event.preventDefault()
  }

  endDraw(event) {
    this.isDrawing = false
    if (event) event.preventDefault()
  }

  setupCanvas() {
    const containerWidth = this.canvasTarget.parentElement?.clientWidth || this.element.clientWidth
    const width = Math.max(280, Math.min(containerWidth, 700))
    const height = 180
    this.canvasTarget.width = width
    this.canvasTarget.height = height
    this.canvasTarget.style.width = `${width}px`
    this.canvasTarget.style.height = `${height}px`
  }

  bindEvents() {
    this.boundBegin = this.beginDraw.bind(this)
    this.boundDraw = this.draw.bind(this)
    this.boundEnd = this.endDraw.bind(this)

    this.canvasTarget.addEventListener("mousedown", this.boundBegin)
    this.canvasTarget.addEventListener("mousemove", this.boundDraw)
    window.addEventListener("mouseup", this.boundEnd)

    this.canvasTarget.addEventListener("touchstart", this.boundBegin, { passive: false })
    this.canvasTarget.addEventListener("touchmove", this.boundDraw, { passive: false })
    window.addEventListener("touchend", this.boundEnd, { passive: false })
    window.addEventListener("touchcancel", this.boundEnd, { passive: false })
  }

  unbindEvents() {
    this.canvasTarget.removeEventListener("mousedown", this.boundBegin)
    this.canvasTarget.removeEventListener("mousemove", this.boundDraw)
    window.removeEventListener("mouseup", this.boundEnd)

    this.canvasTarget.removeEventListener("touchstart", this.boundBegin)
    this.canvasTarget.removeEventListener("touchmove", this.boundDraw)
    window.removeEventListener("touchend", this.boundEnd)
    window.removeEventListener("touchcancel", this.boundEnd)
  }

  pointerPosition(event) {
    const rect = this.canvasTarget.getBoundingClientRect()
    const point = event.touches?.[0] || event.changedTouches?.[0] || event
    return { x: point.clientX - rect.left, y: point.clientY - rect.top }
  }
}
