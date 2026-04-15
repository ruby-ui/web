import { Controller } from "@hotwired/stimulus"
import { createTable, getCoreRowModel } from "@tanstack/table-core"

export default class extends Controller {
  static targets = ["thead", "tbody", "prevButton", "nextButton", "pageIndicator"]
  static values = {
    src: String,
    data: { type: Array, default: [] },
    columns: { type: Array, default: [] },
    rowCount: { type: Number, default: 0 },
    pagination: { type: Object, default: { pageIndex: 0, pageSize: 10 } }
  }

  connect() {
    this.table = createTable({
      data: this.dataValue,
      columns: this.dataValue.length > 0
        ? this.columnsValue.map((c) => ({ id: c.key, accessorKey: c.key, header: c.header }))
        : [],
      getCoreRowModel: getCoreRowModel(),
      renderFallbackValue: null,
      manualPagination: true,
      rowCount: this.rowCountValue,
      state: {},
      onStateChange: () => {}
    })

    this.tableState = {
      ...this.table.initialState,
      pagination: this.paginationValue
    }

    this.table.setOptions((prev) => ({
      ...prev,
      state: this.tableState,
      onPaginationChange: (updater) => {
        const next = typeof updater === "function" ? updater(this.tableState.pagination) : updater
        this.tableState = { ...this.tableState, pagination: next }
        this.table.setOptions((p) => ({ ...p, state: this.tableState }))
        this.#fetchAndRender()
      },
      onStateChange: (updater) => {
        const next = typeof updater === "function" ? updater(this.tableState) : updater
        this.tableState = next
        this.table.setOptions((p) => ({ ...p, state: this.tableState }))
        this.render()
      }
    }))

    this.render()
  }

  previousPage() {
    this.table.previousPage()
  }

  nextPage() {
    this.table.nextPage()
  }

  render() {
    this.#renderHeaders()
    this.#renderRows()
    this.#syncPaginationUI()
  }

  #fetchAndRender() {
    if (!this.hasSrcValue || !this.srcValue) return

    fetch(this.#buildURL(), { headers: { Accept: "application/json" } })
      .then((r) => r.json())
      .then(({ data, row_count }) => {
        this.table.setOptions((prev) => ({
          ...prev,
          data,
          rowCount: row_count,
          state: this.tableState
        }))
        this.render()
      })
  }

  #buildURL() {
    const url = new URL(this.srcValue, window.location.origin)
    const { pageIndex, pageSize } = this.tableState.pagination
    url.searchParams.set("page", pageIndex + 1)
    url.searchParams.set("per_page", pageSize)
    return url.toString()
  }

  #syncPaginationUI() {
    if (this.hasPageIndicatorTarget) {
      const { pageIndex } = this.tableState.pagination
      const pageCount = this.table.getPageCount()
      this.pageIndicatorTarget.textContent = `Page ${pageIndex + 1} of ${pageCount}`
    }
    if (this.hasPrevButtonTarget) {
      this.prevButtonTarget.disabled = !this.table.getCanPreviousPage()
      this.prevButtonTarget.classList.toggle("opacity-50", !this.table.getCanPreviousPage())
      this.prevButtonTarget.classList.toggle("pointer-events-none", !this.table.getCanPreviousPage())
    }
    if (this.hasNextButtonTarget) {
      this.nextButtonTarget.disabled = !this.table.getCanNextPage()
      this.nextButtonTarget.classList.toggle("opacity-50", !this.table.getCanNextPage())
      this.nextButtonTarget.classList.toggle("pointer-events-none", !this.table.getCanNextPage())
    }
  }

  #renderHeaders() {
    if (!this.hasTheadTarget) return

    const html = this.table.getHeaderGroups().map((group) => {
      const cells = group.headers.map((header) => {
        const def = header.column.columnDef.header
        const label = typeof def === "function" ? def(header.getContext()) : def
        return `<th class="h-10 px-2 text-left align-middle font-medium text-muted-foreground">${escapeHtml(label ?? "")}</th>`
      }).join("")
      return `<tr class="border-b transition-colors">${cells}</tr>`
    }).join("")

    this.theadTarget.innerHTML = html
  }

  #renderRows() {
    if (!this.hasTbodyTarget) return

    const rows = this.table.getRowModel().rows
    if (rows.length === 0) {
      this.tbodyTarget.innerHTML = `<tr><td class="h-24 text-center text-muted-foreground" colspan="${this.columnsValue.length || 1}">No results.</td></tr>`
      return
    }

    const html = rows.map((row) => {
      const cells = row.getVisibleCells().map((cell) => {
        const value = cell.getValue()
        return `<td class="p-2 align-middle">${escapeHtml(value ?? "")}</td>`
      }).join("")
      return `<tr class="border-b transition-colors hover:bg-muted/50">${cells}</tr>`
    }).join("")

    this.tbodyTarget.innerHTML = html
  }
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;")
}
