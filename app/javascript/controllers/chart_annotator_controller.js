import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["file", "baseCanvas", "drawCanvas", "placeholder", "hidden", "color", "size", "eraser"]
  static values = { defaultImageUrl: String }

  connect() {
    this.baseCtx = this.baseCanvasTarget.getContext("2d")
    this.drawCtx = this.drawCanvasTarget.getContext("2d")
    this.isDrawing = false
    this.hasMarks = false
    this.lastX = 0
    this.lastY = 0
    this.brushColor = "#c0392b"
    this.brushSize = 3
    this.eraserMode = false

    this.setupCanvasSize()
    this.bindEvents()
    requestAnimationFrame(() => this.renderInitialTemplate())

    this.boundResize = this.handleResize.bind(this)
    window.addEventListener("resize", this.boundResize)
  }

  disconnect() {
    this.unbindEvents()
    window.removeEventListener("resize", this.boundResize)
  }

  loadImage(event) {
    const file = event.target.files?.[0]
    if (!file) {
      this.resetCanvas()
      return
    }

    const reader = new FileReader()
    reader.onload = () => {
      const image = new Image()
      image.onload = () => {
        this.setupCanvasSize(image.width, image.height)
        this.baseCtx.clearRect(0, 0, this.baseCanvasTarget.width, this.baseCanvasTarget.height)
        this.baseCtx.drawImage(image, 0, 0, this.baseCanvasTarget.width, this.baseCanvasTarget.height)
        this.clearOverlay()
        if (this.hasPlaceholderTarget) this.placeholderTarget.classList.add("hidden")
      }
      image.src = reader.result
    }
    reader.readAsDataURL(file)
  }

  clearCanvas() {
    this.clearOverlay()
  }

  updateBrushColor(event) {
    this.brushColor = event.target.value || "#c0392b"
    this.eraserMode = false
    this.syncEraserButton()
  }

  updateBrushSize(event) {
    this.brushSize = Number(event.target.value || 3)
  }

  toggleEraser() {
    this.eraserMode = !this.eraserMode
    this.syncEraserButton()
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
    this.drawCtx.save()
    this.drawCtx.globalCompositeOperation = this.eraserMode ? "destination-out" : "source-over"
    this.drawCtx.strokeStyle = this.brushColor
    this.drawCtx.lineWidth = this.brushSize
    this.drawCtx.lineCap = "round"
    this.drawCtx.lineJoin = "round"
    this.drawCtx.beginPath()
    this.drawCtx.moveTo(this.lastX, this.lastY)
    this.drawCtx.lineTo(x, y)
    this.drawCtx.stroke()
    this.drawCtx.restore()

    this.lastX = x
    this.lastY = y
    this.hasMarks = true
    this.serializeCanvas()
    event.preventDefault()
  }

  endDraw(event) {
    this.isDrawing = false
    if (event) event.preventDefault()
  }

  setupCanvasSize(sourceWidth = 1000, sourceHeight = 700) {
    const maxWidth = Math.min(this.element.clientWidth - 24, 1000)
    const ratio = sourceHeight / sourceWidth
    const width = Math.max(320, Math.floor(maxWidth))
    const height = Math.max(220, Math.floor(width * ratio))

    ;[this.baseCanvasTarget, this.drawCanvasTarget].forEach((canvas) => {
      canvas.width = width
      canvas.height = height
      canvas.style.width = `${width}px`
      canvas.style.height = `${height}px`
    })
  }

  bindEvents() {
    this.boundBegin = this.beginDraw.bind(this)
    this.boundDraw = this.draw.bind(this)
    this.boundEnd = this.endDraw.bind(this)

    this.drawCanvasTarget.addEventListener("mousedown", this.boundBegin)
    this.drawCanvasTarget.addEventListener("mousemove", this.boundDraw)
    window.addEventListener("mouseup", this.boundEnd)

    this.drawCanvasTarget.addEventListener("touchstart", this.boundBegin, { passive: false })
    this.drawCanvasTarget.addEventListener("touchmove", this.boundDraw, { passive: false })
    window.addEventListener("touchend", this.boundEnd, { passive: false })
    window.addEventListener("touchcancel", this.boundEnd, { passive: false })
  }

  unbindEvents() {
    this.drawCanvasTarget.removeEventListener("mousedown", this.boundBegin)
    this.drawCanvasTarget.removeEventListener("mousemove", this.boundDraw)
    window.removeEventListener("mouseup", this.boundEnd)

    this.drawCanvasTarget.removeEventListener("touchstart", this.boundBegin)
    this.drawCanvasTarget.removeEventListener("touchmove", this.boundDraw)
    window.removeEventListener("touchend", this.boundEnd)
    window.removeEventListener("touchcancel", this.boundEnd)
  }

  pointerPosition(event) {
    const rect = this.drawCanvasTarget.getBoundingClientRect()
    const point = event.touches?.[0] || event.changedTouches?.[0] || event
    return { x: point.clientX - rect.left, y: point.clientY - rect.top }
  }

  serializeCanvas() {
    try {
      const exportCanvas = document.createElement("canvas")
      exportCanvas.width = this.baseCanvasTarget.width
      exportCanvas.height = this.baseCanvasTarget.height
      const exportCtx = exportCanvas.getContext("2d")
      exportCtx.drawImage(this.baseCanvasTarget, 0, 0)
      exportCtx.drawImage(this.drawCanvasTarget, 0, 0)
      this.hiddenTarget.value = exportCanvas.toDataURL("image/png")
    } catch (_error) {
      this.hiddenTarget.value = ""
    }
  }

  clearOverlay() {
    this.drawCtx.clearRect(0, 0, this.drawCanvasTarget.width, this.drawCanvasTarget.height)
    this.hasMarks = false
    this.hiddenTarget.value = ""
  }

  resetCanvas() {
    this.setupCanvasSize()
    this.baseCtx.clearRect(0, 0, this.baseCanvasTarget.width, this.baseCanvasTarget.height)
    this.clearOverlay()
    this.eraserMode = false
    this.syncEraserButton()
    this.renderInitialTemplate()
  }

  handleResize() {
    if (this.hasMarks) return
    this.setupCanvasSize()
    this.renderInitialTemplate()
  }

  renderInitialTemplate() {
    if (this.hasDefaultImageUrlValue && this.defaultImageUrlValue && this.defaultImageUrlValue.trim().length > 0) {
      this.loadRemoteDefaultImage(this.defaultImageUrlValue)
      return
    }

    this.renderBlankCanvas()
  }

  loadRemoteDefaultImage(url) {
    const image = new Image()
    image.crossOrigin = "anonymous"
    image.onload = () => {
      this.setupCanvasSize(image.width, image.height)
      this.baseCtx.clearRect(0, 0, this.baseCanvasTarget.width, this.baseCanvasTarget.height)
      this.baseCtx.fillStyle = "#ffffff"
      this.baseCtx.fillRect(0, 0, this.baseCanvasTarget.width, this.baseCanvasTarget.height)
      this.baseCtx.drawImage(image, 0, 0, this.baseCanvasTarget.width, this.baseCanvasTarget.height)
      this.clearOverlay()
      if (this.hasPlaceholderTarget) this.placeholderTarget.classList.add("hidden")
    }
    image.onerror = () => this.renderBlankCanvas()
    image.src = url
  }

  renderBlankCanvas() {
    this.baseCtx.clearRect(0, 0, this.baseCanvasTarget.width, this.baseCanvasTarget.height)
    this.baseCtx.fillStyle = "#ffffff"
    this.baseCtx.fillRect(0, 0, this.baseCanvasTarget.width, this.baseCanvasTarget.height)
    this.clearOverlay()
    if (this.hasPlaceholderTarget) this.placeholderTarget.classList.remove("hidden")
  }

  syncEraserButton() {
    if (!this.hasEraserTarget) return
    this.eraserTarget.classList.toggle("bg-stone-800", this.eraserMode)
    this.eraserTarget.classList.toggle("text-white", this.eraserMode)
  }
}
