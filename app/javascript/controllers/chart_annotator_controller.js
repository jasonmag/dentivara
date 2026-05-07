import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["file", "canvas", "placeholder", "hidden", "clear", "color", "size", "eraser", "status", "surfaceData"]
  static values = { defaultImageUrl: String }

  connect() {
    this.ctx = this.canvasTarget.getContext("2d")
    this.isDrawing = false
    this.hasMarks = false
    this.lastX = 0
    this.lastY = 0
    this.brushColor = "#c0392b"
    this.brushSize = 3
    this.eraserMode = false
    this.surfaceRects = []
    this.activeStatus = "caries"
    this.statusStyles = {
      caries: { color: "rgba(220, 38, 38, 0.55)", stroke: "#991b1b" },
      filling: { color: "rgba(37, 99, 235, 0.45)", stroke: "#1d4ed8" },
      missing: { color: "rgba(71, 85, 105, 0.5)", stroke: "#334155" },
      crown: { color: "rgba(245, 158, 11, 0.45)", stroke: "#b45309" },
      root_canal: { color: "rgba(16, 185, 129, 0.45)", stroke: "#047857" },
      watch: { color: "rgba(168, 85, 247, 0.45)", stroke: "#7e22ce" }
    }
    this.surfaceMarks = []
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
        this.ctx.clearRect(0, 0, this.canvasTarget.width, this.canvasTarget.height)
        this.ctx.drawImage(image, 0, 0, this.canvasTarget.width, this.canvasTarget.height)
        this.hasMarks = false
        this.hiddenTarget.value = ""
        this.surfaceMarks = []
        this.serializeSurfaceMarks()
        this.placeholderTarget.classList.add("hidden")
      }
      image.src = reader.result
    }
    reader.readAsDataURL(file)
  }

  clearCanvas() {
    this.resetCanvas()
  }

  updateBrushColor(event) {
    this.brushColor = event.target.value || "#c0392b"
    this.eraserMode = false
    this.syncEraserButton()
  }

  updateBrushSize(event) {
    this.brushSize = Number(event.target.value || 3)
  }

  updateStatus(event) {
    this.activeStatus = event.target.value || "caries"
  }

  toggleEraser() {
    this.eraserMode = !this.eraserMode
    this.syncEraserButton()
  }

  beginDraw(event) {
    if (!this.canvasTarget) return
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
    this.ctx.strokeStyle = this.eraserMode ? "#ffffff" : this.brushColor
    this.ctx.lineWidth = this.brushSize
    this.ctx.lineCap = "round"
    this.ctx.lineJoin = "round"
    this.ctx.beginPath()
    this.ctx.moveTo(this.lastX, this.lastY)
    this.ctx.lineTo(x, y)
    this.ctx.stroke()
    this.ctx.restore()

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
    this.canvasTarget.addEventListener("click", this.handleSurfaceClick.bind(this))
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
    const x = point.clientX - rect.left
    const y = point.clientY - rect.top
    return { x, y }
  }

  serializeCanvas() {
    if (!this.hasMarks) return
    try {
      this.hiddenTarget.value = this.canvasTarget.toDataURL("image/png")
    } catch (_error) {
      this.hiddenTarget.value = ""
    }
  }

  resetCanvas() {
    this.setupCanvasSize()
    this.ctx.clearRect(0, 0, this.canvasTarget.width, this.canvasTarget.height)
    this.hiddenTarget.value = ""
    this.surfaceMarks = []
    this.serializeSurfaceMarks()
    this.hasMarks = false
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

    this.renderDefaultChart()
  }

  loadRemoteDefaultImage(url) {
    const image = new Image()
    image.crossOrigin = "anonymous"

    image.onload = () => {
      this.setupCanvasSize(image.width, image.height)
      this.surfaceRects = []
      this.ctx.clearRect(0, 0, this.canvasTarget.width, this.canvasTarget.height)
      this.ctx.fillStyle = "#ffffff"
      this.ctx.fillRect(0, 0, this.canvasTarget.width, this.canvasTarget.height)
      this.ctx.drawImage(image, 0, 0, this.canvasTarget.width, this.canvasTarget.height)
      if (this.hasPlaceholderTarget) this.placeholderTarget.classList.add("hidden")
    }

    image.onerror = () => {
      this.renderDefaultChart()
    }

    image.src = url
  }

  renderDefaultChart() {
    const canvas = this.canvasTarget
    const ctx = this.ctx
    const w = canvas.width
    const h = canvas.height
    this.surfaceRects = []

    ctx.clearRect(0, 0, w, h)
    ctx.fillStyle = "#ffffff"
    ctx.fillRect(0, 0, w, h)

    const margin = 24
    const rowGap = 44
    const rowHeight = (h - margin * 2 - rowGap) / 2
    const colCount = 16
    const cellGap = 4
    const cellWidth = (w - margin * 2 - cellGap * (colCount - 1)) / colCount

    ctx.fillStyle = "#0f172a"
    ctx.font = "600 14px Manrope, sans-serif"
    ctx.fillText("Default Odontogram (FDI Adult 18-48)", margin, 18)

    this.drawToothRow({
      labels: ["18", "17", "16", "15", "14", "13", "12", "11", "21", "22", "23", "24", "25", "26", "27", "28"],
      y: margin,
      rowHeight,
      cellWidth,
      cellGap,
      colCount,
      margin,
      isUpper: true
    })

    this.drawToothRow({
      labels: ["48", "47", "46", "45", "44", "43", "42", "41", "31", "32", "33", "34", "35", "36", "37", "38"],
      y: margin + rowHeight + rowGap,
      rowHeight,
      cellWidth,
      cellGap,
      colCount,
      margin,
      isUpper: false
    })

    this.drawQuadrantDivider(margin, margin + rowHeight + rowGap / 2, w - margin)
    this.drawMidlineDivider(margin + ((cellWidth + cellGap) * 8) - (cellGap / 2), margin, margin + rowHeight * 2 + rowGap)

    if (this.hasPlaceholderTarget) this.placeholderTarget.classList.add("hidden")
  }

  drawToothRow({ labels, y, rowHeight, cellWidth, cellGap, colCount, margin, isUpper }) {
    const ctx = this.ctx
    for (let i = 0; i < colCount; i += 1) {
      const x = margin + i * (cellWidth + cellGap)
      const toothNumber = labels[i]

      const padX = Math.max(2, cellWidth * 0.16)
      const padY = Math.max(3, rowHeight * 0.14)
      const tx = x + padX
      const ty = y + padY
      const tw = cellWidth - padX * 2
      const th = rowHeight - padY * 2

      this.drawToothShape(tx, ty, tw, th, isUpper)
      this.drawToothSurfaces(tx, ty, tw, th, toothNumber)

      ctx.fillStyle = "#334155"
      ctx.font = "600 10px Manrope, sans-serif"
      ctx.fillText(String(toothNumber), x + 4, y + 12)
    }
  }

  drawToothShape(x, y, w, h, isUpper) {
    const ctx = this.ctx
    const cx = x + w / 2
    const top = y
    const bottom = y + h
    const left = x
    const right = x + w
    const crownY = y + h * 0.42

    ctx.save()
    ctx.beginPath()
    ctx.moveTo(cx, top)
    ctx.bezierCurveTo(x + w * 0.2, y + h * 0.05, left, y + h * 0.2, left, crownY)
    ctx.bezierCurveTo(left, y + h * 0.7, x + w * 0.28, y + h * 0.86, x + w * 0.4, bottom)
    ctx.lineTo(x + w * 0.5, y + h * 0.82)
    ctx.lineTo(x + w * 0.6, bottom)
    ctx.bezierCurveTo(x + w * 0.72, y + h * 0.86, right, y + h * 0.7, right, crownY)
    ctx.bezierCurveTo(right, y + h * 0.2, x + w * 0.8, y + h * 0.05, cx, top)
    ctx.closePath()

    ctx.fillStyle = "#ffffff"
    ctx.strokeStyle = "#475569"
    ctx.lineWidth = 1.35
    ctx.fill()
    ctx.stroke()

    ctx.beginPath()
    if (isUpper) {
      ctx.moveTo(x + w * 0.28, y + h * 0.34)
      ctx.quadraticCurveTo(cx, y + h * 0.25, x + w * 0.72, y + h * 0.34)
    } else {
      ctx.moveTo(x + w * 0.28, y + h * 0.66)
      ctx.quadraticCurveTo(cx, y + h * 0.75, x + w * 0.72, y + h * 0.66)
    }
    ctx.strokeStyle = "#94a3b8"
    ctx.lineWidth = 1
    ctx.stroke()
    ctx.restore()
  }

  drawToothSurfaces(x, y, w, h, toothNumber) {
    const ctx = this.ctx
    const cx = x + w / 2
    const cy = y + h / 2
    const centerW = w * 0.36
    const centerH = h * 0.32

    const left = x + 1
    const right = x + w - 1
    const top = y + 1
    const bottom = y + h - 1
    const cLeft = cx - centerW / 2
    const cRight = cx + centerW / 2
    const cTop = cy - centerH / 2
    const cBottom = cy + centerH / 2

    ctx.save()
    ctx.strokeStyle = "#64748b"
    ctx.lineWidth = 0.9
    ctx.fillStyle = "rgba(255,255,255,0.6)"

    this.strokeSurfaceQuad(left, cTop, cLeft, cBottom, toothNumber, "M")
    this.strokeSurfaceQuad(cRight, cTop, right, cBottom, toothNumber, "D")
    this.strokeSurfaceQuad(cLeft, top, cRight, cTop, toothNumber, "B")
    this.strokeSurfaceQuad(cLeft, cBottom, cRight, bottom, toothNumber, "L")
    this.strokeSurfaceQuad(cLeft, cTop, cRight, cBottom, toothNumber, "O", true)

    ctx.fillStyle = "#1f2937"
    ctx.font = "600 7px Manrope, sans-serif"
    ctx.fillText("M", left + 2, cy + 2)
    ctx.fillText("D", right - 7, cy + 2)
    ctx.fillText("B", cx - 2, top + 8)
    ctx.fillText("L", cx - 2, bottom - 2)
    ctx.fillText("O", cx - 2, cy + 2)
    ctx.restore()
  }

  strokeSurfaceQuad(x1, y1, x2, y2, toothNumber, surfaceLabel, fill = false) {
    const ctx = this.ctx
    this.surfaceRects.push({
      toothNumber,
      surfaceLabel,
      x: x1,
      y: y1,
      w: x2 - x1,
      h: y2 - y1
    })
    ctx.beginPath()
    ctx.rect(x1, y1, x2 - x1, y2 - y1)
    if (fill) ctx.fill()
    ctx.stroke()
  }

  handleSurfaceClick(event) {
    if (this.isDrawing || this.eraserMode) return

    const { x, y } = this.pointerPosition(event)
    const hit = this.surfaceRects.find((rect) => (
      x >= rect.x && x <= rect.x + rect.w && y >= rect.y && y <= rect.y + rect.h
    ))
    if (!hit) return

    const style = this.statusStyles[this.activeStatus] || this.statusStyles.caries
    this.ctx.save()
    this.ctx.fillStyle = style.color
    this.ctx.strokeStyle = style.stroke
    this.ctx.lineWidth = 1
    this.ctx.fillRect(hit.x, hit.y, hit.w, hit.h)
    this.ctx.strokeRect(hit.x, hit.y, hit.w, hit.h)
    this.ctx.restore()

    this.ctx.save()
    this.ctx.fillStyle = "#111827"
    this.ctx.font = "600 8px Manrope, sans-serif"
    this.ctx.fillText(hit.surfaceLabel, hit.x + 2, hit.y + 10)
    this.ctx.restore()

    this.upsertSurfaceMark(hit.toothNumber, hit.surfaceLabel, this.activeStatus)
    this.serializeSurfaceMarks()
    this.hasMarks = true
    this.serializeCanvas()
  }

  upsertSurfaceMark(tooth, surface, status) {
    const existingIndex = this.surfaceMarks.findIndex((item) => item.tooth == tooth && item.surface == surface)
    const next = { tooth, surface, status }
    if (existingIndex >= 0) {
      this.surfaceMarks[existingIndex] = next
    } else {
      this.surfaceMarks.push(next)
    }
  }

  serializeSurfaceMarks() {
    if (!this.hasSurfaceDataTarget) return
    this.surfaceDataTarget.value = JSON.stringify(this.surfaceMarks)
  }

  drawQuadrantDivider(x1, y, x2) {
    const ctx = this.ctx
    ctx.save()
    ctx.setLineDash([5, 4])
    ctx.strokeStyle = "#94a3b8"
    ctx.lineWidth = 1
    ctx.beginPath()
    ctx.moveTo(x1, y)
    ctx.lineTo(x2, y)
    ctx.stroke()
    ctx.restore()
  }

  drawMidlineDivider(x, y1, y2) {
    const ctx = this.ctx
    ctx.save()
    ctx.setLineDash([5, 4])
    ctx.strokeStyle = "#94a3b8"
    ctx.lineWidth = 1
    ctx.beginPath()
    ctx.moveTo(x, y1)
    ctx.lineTo(x, y2)
    ctx.stroke()
    ctx.restore()
  }

  syncEraserButton() {
    if (!this.hasEraserTarget) return

    if (this.eraserMode) {
      this.eraserTarget.classList.add("bg-stone-800", "text-white")
    } else {
      this.eraserTarget.classList.remove("bg-stone-800", "text-white")
    }
  }
}
