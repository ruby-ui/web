import { Controller } from "@hotwired/stimulus"
import { createTable, getCoreRowModel } from "@tanstack/table-core"

export default class extends Controller {
  static targets = ["thead", "tbody", "prevButton", "nextButton", "pageIndicator"]
  static values = {
    src: String,
    data: { type: Array, default: [] },
    columns: { type: Array, default: [] },
    rowCount: { type: Number, default: 0 },
    pagination: { type: Object, default: { pageIndex: 0, pageSize: 10 } },
    sorting: { type: Array, default: [] }
  }

  connect() {
    this.table = createTable({
      data: this.dataValue,
      columns: this.columnsValue.map((c) => ({
        id: c.key,
        accessorKey: c.key,
        header: c.header
      })),
      getCoreRowModel: getCoreRowModel(),
      renderFallbackValue: null,
      manualPagination: true,
      manualSorting: true,
      rowCount: this.rowCountValue,
      state: {},
      onStateChange: () => {}
    })

    this.tableState = {
      ...this.table.initialState,
      pagination: this.paginationValue,
      sorting: this.sortingValue
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
      onSortingChange: (updater) => {
        const next = typeof updater === "function" ? updater(this.tableState.sorting) : updater
        this.tableState = {
          ...this.tableState,
          sorting: next,
          pagination: { ...this.tableState.pagination, pageIndex: 0 }
        }
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

  previousPage() { this.table.previousPage() }
  nextPage() { this.table.nextPage() }

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

    if (this.tableState.sorting.length > 0) {
      const { id, desc } = this.tableState.sorting[0]
      url.searchParams.set("sort", id)
      url.searchParams.set("direction", desc ? "desc" : "asc")
    }

    return url.toString()
  }

  #syncPaginationUI() {
    if (this.hasPageIndicatorTarget) {
      const { pageIndex } = this.tableState.pagination
      const pageCount = this.table.getPageCount()
      this.pageIndicatorTarget.textContent = `Page ${pageIndex + 1} of ${pageCount}`
    }
    if (this.hasPrevButtonTarget) {
      const can = this.table.getCanPreviousPage()
      this.prevButtonTarget.disabled = !can
      this.prevButtonTarget.classList.toggle("opacity-50", !can)
      this.prevButtonTarget.classList.toggle("pointer-events-none", !can)
    }
    if (this.hasNextButtonTarget) {
      const can = this.table.getCanNextPage()
      this.nextButtonTarget.disabled = !can
      this.nextButtonTarget.classList.toggle("opacity-50", !can)
      this.nextButtonTarget.classList.toggle("pointer-events-none", !can)
    }
  }

  #renderHeaders() {
    if (!this.hasTheadTarget) return

    const html = this.table.getHeaderGroups().map((group) => {
      const cells = group.headers.map((header) => {
        const def = header.column.columnDef.header
        const label = typeof def === "function" ? def(header.getContext()) : (def ?? "")
        const sorted = header.column.getIsSorted() // false | "asc" | "desc"
        const canSort = header.column.getCanSort()

        if (!canSort) {
          return `<th class="h-10 px-2 text-left align-middle font-medium text-muted-foreground">${escapeHtml(label)}</th>`
        }

        const icon = sorted === "asc"
          ? `<svg class="ml-1 inline-block w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m18 15-6-6-6 6"/></svg>`
          : sorted === "desc"
          ? `<svg class="ml-1 inline-block w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m6 9 6 6 6-6"/></svg>`
          : `<svg class="ml-1 inline-block w-3 h-3 opacity-30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m7 15 5 5 5-5M7 9l5-5 5 5"/></svg>`

        return `<th class="h-10 px-2 text-left align-middle font-medium text-muted-foreground">
          <button class="flex items-center gap-1 hover:text-foreground transition-colors" data-sort-col="${header.column.id}">
            ${escapeHtml(label)}${icon}
          </button>
        </th>`
      }).join("")
      return `<tr class="border-b transition-colors">${cells}</tr>`
    }).join("")

    this.theadTarget.innerHTML = html

    // Attach sort handlers after render (avoid inline onclick with private methods)
    this.theadTarget.querySelectorAll("[data-sort-col]").forEach((btn) => {
      btn.addEventListener("click", () => this.#sortColumn(btn.dataset.sortCol))
    })
  }

  #sortColumn(colId) {
    const col = this.table.getColumn(colId)
    if (col) col.toggleSorting()
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
