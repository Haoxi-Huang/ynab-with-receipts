import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image"]

  toggle() {
    this.imageTarget.classList.toggle("scale-150")
    this.imageTarget.classList.toggle("cursor-zoom-in")
    this.imageTarget.classList.toggle("cursor-zoom-out")
    this.element.classList.toggle("overflow-hidden")
    this.element.classList.toggle("overflow-auto")
  }
}
