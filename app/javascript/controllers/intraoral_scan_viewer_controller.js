import { Controller } from "@hotwired/stimulus"
import * as THREE from "three"
import { OrbitControls } from "three/addons/controls/OrbitControls.js"
import { OBJLoader } from "three/addons/loaders/OBJLoader.js"
import { PLYLoader } from "three/addons/loaders/PLYLoader.js"
import { STLLoader } from "three/addons/loaders/STLLoader.js"

export default class extends Controller {
  static targets = ["viewport", "status"]
  static values = { url: String, extension: String }

  connect() {
    if (!this.hasViewportTarget || !this.urlValue) return

    this.setupScene()
    this.loadModel()
    this.animate()
    this.resizeObserver = new ResizeObserver(() => this.resize())
    this.resizeObserver.observe(this.viewportTarget)
  }

  disconnect() {
    this.resizeObserver?.disconnect()
    cancelAnimationFrame(this.animationFrame)
    this.renderer?.dispose()
    this.viewportTarget.innerHTML = ""
  }

  setupScene() {
    this.scene = new THREE.Scene()
    this.scene.background = new THREE.Color(0xf8faf7)

    const { width, height } = this.viewportSize()
    this.camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 10000)
    this.camera.position.set(0, 70, 180)

    this.renderer = new THREE.WebGLRenderer({ antialias: true })
    this.renderer.setPixelRatio(window.devicePixelRatio)
    this.renderer.setSize(width, height)
    this.viewportTarget.appendChild(this.renderer.domElement)

    this.controls = new OrbitControls(this.camera, this.renderer.domElement)
    this.controls.enableDamping = true

    this.scene.add(new THREE.HemisphereLight(0xffffff, 0x667766, 2.2))
    const directionalLight = new THREE.DirectionalLight(0xffffff, 2.5)
    directionalLight.position.set(120, 160, 120)
    this.scene.add(directionalLight)
    this.scene.add(new THREE.GridHelper(220, 22, 0xb8c2b4, 0xe4e9df))
  }

  loadModel() {
    this.statusTarget.textContent = "Loading scan preview..."
    const extension = this.extensionValue.toLowerCase()

    if (extension === "stl") return this.loadGeometry(new STLLoader())
    if (extension === "ply") return this.loadGeometry(new PLYLoader())
    if (extension === "obj") return this.loadObject(new OBJLoader())

    this.statusTarget.textContent = "Online 3D preview is available for STL, PLY, and OBJ files."
  }

  loadGeometry(loader) {
    loader.load(this.urlValue, (geometry) => {
      geometry.computeVertexNormals()
      const material = new THREE.MeshStandardMaterial({ color: 0x8ba88e, roughness: 0.45, metalness: 0.05 })
      this.addModel(new THREE.Mesh(geometry, material))
    }, undefined, () => {
      this.statusTarget.textContent = "Unable to load scan preview."
    })
  }

  loadObject(loader) {
    loader.load(this.urlValue, (object) => this.addModel(object), undefined, () => {
      this.statusTarget.textContent = "Unable to load scan preview."
    })
  }

  addModel(model) {
    const box = new THREE.Box3().setFromObject(model)
    const center = box.getCenter(new THREE.Vector3())
    const size = box.getSize(new THREE.Vector3())
    const maxAxis = Math.max(size.x, size.y, size.z) || 1

    model.position.sub(center)
    model.scale.multiplyScalar(120 / maxAxis)
    this.scene.add(model)

    this.camera.position.set(0, 70, 190)
    this.controls.target.set(0, 0, 0)
    this.controls.update()
    this.statusTarget.textContent = "Use mouse or touch to rotate, pan, and zoom."
  }

  animate() {
    this.animationFrame = requestAnimationFrame(() => this.animate())
    this.controls?.update()
    this.renderer?.render(this.scene, this.camera)
  }

  resize() {
    if (!this.camera || !this.renderer) return

    const { width, height } = this.viewportSize()
    this.camera.aspect = width / height
    this.camera.updateProjectionMatrix()
    this.renderer.setSize(width, height)
  }

  viewportSize() {
    return {
      width: Math.max(this.viewportTarget.clientWidth, 320),
      height: Math.max(this.viewportTarget.clientHeight, 420)
    }
  }
}
