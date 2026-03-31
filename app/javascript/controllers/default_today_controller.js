import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (this.element.value) return

    const now = new Date()
    const yyyy = now.getFullYear()
    const mm = String(now.getMonth() + 1).padStart(2, "0")
    const dd = String(now.getDate()).padStart(2, "0")
    this.element.value = `${yyyy}-${mm}-${dd}`
  }
}
