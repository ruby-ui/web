import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search", "perPage"]
  static values = {
    src: String,
    sortColumn: String,
    sortDirection: String,
    page: { type: Number, default: 1 },
    perPage: { type: Number, default: 10 },
    searchQuery: String,
    debounceMs: { type: Number, default: 300 }
  }

  connect() {
    this.searchTimeout = null
  }

  disconnect() {
    if (this.searchTimeout) clearTimeout(this.searchTimeout)
  }

  sort(event) {
    const { column, direction } = event.params
    this.sortColumnValue = column
    this.sortDirectionValue = direction || ""
    this.pageValue = 1
    this._reload()
  }

  search() {
    if (this.searchTimeout) clearTimeout(this.searchTimeout)
    this.searchTimeout = setTimeout(() => {
      this.searchQueryValue = this.searchTarget.value
      this.pageValue = 1
      this._reload()
    }, this.debounceMsValue)
  }

  nextPage() {
    this.pageValue += 1
    this._reload()
  }

  previousPage() {
    if (this.pageValue > 1) {
      this.pageValue -= 1
      this._reload()
    }
  }

  changePerPage() {
    this.perPageValue = parseInt(this.perPageTarget.value)
    this.pageValue = 1
    this._reload()
  }

  _reload() {
    if (!this.hasSrcValue || !this.srcValue) return

    const url = new URL(this.srcValue, window.location.origin)
    if (this.sortColumnValue) url.searchParams.set("sort", this.sortColumnValue)
    if (this.sortDirectionValue) url.searchParams.set("direction", this.sortDirectionValue)
    if (this.searchQueryValue) url.searchParams.set("search", this.searchQueryValue)
    url.searchParams.set("page", this.pageValue)
    url.searchParams.set("per_page", this.perPageValue)

    // Use Turbo to fetch and replace the content frame
    const frame = this.element.querySelector("turbo-frame")
    if (frame) {
      frame.src = url.toString()
    } else {
      // Fallback: dispatch custom event for consumer to handle
      this.dispatch("navigate", { detail: { url: url.toString() } })
    }
  }
}
