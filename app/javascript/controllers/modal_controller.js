import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.body.classList.add("overflow-hidden")
  }

  disconnect() {
    document.body.classList.remove("overflow-hidden")
  }

  close(event) {
    if (event.target === this.element) {
      this.element.remove()
      document.body.classList.remove("overflow-hidden")
    }
  }
}
