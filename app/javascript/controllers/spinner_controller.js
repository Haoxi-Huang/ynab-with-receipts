import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this._form = this.element.closest("form")
    if (!this._form) return

    this._form.addEventListener("turbo:submit-start", this._start)
    this._form.addEventListener("turbo:submit-end", this._end)
  }

  disconnect() {
    if (!this._form) return
    this._form.removeEventListener("turbo:submit-start", this._start)
    this._form.removeEventListener("turbo:submit-end", this._end)
  }

  _start = () => {
    this.element.disabled = true
    const template = document.querySelector("[data-spinner-template]")

    if (this.element instanceof HTMLInputElement) {
      this._originalValue = this.element.value
      this.element.style.color = "transparent"
      const overlay = document.createElement("span")
      overlay.innerHTML = template.innerHTML
      overlay.className = "absolute inset-0 flex items-center justify-center"
      overlay.dataset.spinnerOverlay = ""
      this.element.parentElement.classList.add("relative")
      this.element.parentElement.appendChild(overlay)
    } else {
      this._originalHTML = this.element.innerHTML
      this.element.innerHTML = template.innerHTML
    }
  }

  _end = () => {
    this.element.disabled = false

    if (this.element instanceof HTMLInputElement) {
      this.element.style.color = ""
      const overlay = this.element.parentElement.querySelector("[data-spinner-overlay]")
      if (overlay) overlay.remove()
      this.element.parentElement.classList.remove("relative")
    } else if (this._originalHTML !== undefined) {
      this.element.innerHTML = this._originalHTML
    }
  }
}
