import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  static values = { url: String, receiptId: String }

  perform() {
    clearTimeout(this._timeout)
    this._timeout = setTimeout(() => this._search(), 300)
  }

  async _search() {
    const query = this.inputTarget.value.trim()
    if (query.length < 2) {
      this.resultsTarget.classList.add("hidden")
      document.getElementById("suggestions-list").classList.remove("hidden")
      return
    }

    const url = `${this.urlValue}?q=${encodeURIComponent(query)}&receipt_id=${this.receiptIdValue}`
    try {
      const response = await fetch(url, {
        headers: {
          "Accept": "text/html",
          "X-Requested-With": "XMLHttpRequest"
        }
      })
      const html = await response.text()
      this.resultsTarget.innerHTML = html
      this.resultsTarget.classList.remove("hidden")
      document.getElementById("suggestions-list").classList.add("hidden")
    } catch (e) {
      console.error("Search failed:", e)
    }
  }
}
