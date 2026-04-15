import { Controller } from "@hotwired/stimulus"
import { createTable, getCoreRowModel, getSortedRowModel } from "@tanstack/table-core"

export default class extends Controller {
  static targets = ["thead", "tbody", "prevButton", "nextButton", "pageIndicator", "search", "perPage", "bulkActions"]
  static values = {
    src: String,
    data: { type: Array, default: [] },
    columns: { type: Array, default: [] },
    rowCount: { type: Number, default: 0 },
    pagination: { type: Object, default: { pageIndex: 0, pageSize: 10 } },
    sorting: { type: Array, default: [] },
    search: { type: String, default: "" },
    selectable: { type: Boolean, default: false }
  }

  connect() {
    this.searchTimeout = null
    this.rowSelection = {}

    this.hasServer = this.hasSrcValue && !!this.srcValue

    const columnDefs = this.columnsValue.map((c) => ({
      id: c.key,
      accessorKey: c.key,
      header: c.header,
      meta: { type: c.type ?? "text", colors: c.colors ?? null }
    }))

    this.table = createTable({
      data: this.dataValue,
      columns: columnDefs,
      getCoreRowModel: getCoreRowModel(),
      getSortedRowModel: this.hasServer ? undefined : getSortedRowModel(),
      renderFallbackValue: null,
      manualPagination: this.hasServer,
      manualSorting: this.hasServer,
      manualFiltering: this.hasServer,
      rowCount: this.rowCountValue,
      enableRowSelection: this.selectableValue,
      enableMultiRowSelection: true,
      getRowId: (row) => String(row.id ?? row[Object.keys(row)[0]]),
      state: {},
      onStateChange: () => {}
    })

    this.tableState = {
      ...this.table.initialState,
      pagination: this.paginationValue,
      sorting: this.sortingValue,
      globalFilter: this.searchValue,
      rowSelection: this.rowSelection
    }

    this.table.setOptions((prev) => ({
      ...prev,
      state: this.tableState,
      onPaginationChange: (updater) => {
        const next = typeof updater === "function" ? updater(this.tableState.pagination) : updater
        this.rowSelection = {}
        this.tableState = { ...this.tableState, pagination: next, rowSelection: {} }
        this.table.setOptions((p) => ({ ...p, state: this.tableState }))
        this.#fetchAndRender()
      },
      onSortingChange: (updater) => {
        const next = typeof updater === "function" ? updater(this.tableState.sorting) : updater
        this.rowSelection = {}
        this.tableState = {
          ...this.tableState,
          sorting: next,
          pagination: { ...this.tableState.pagination, pageIndex: 0 },
          rowSelection: {}
        }
        this.table.setOptions((p) => ({ ...p, state: this.tableState }))
        if (this.hasServer) {
          this.#fetchAndRender()
        } else {
          this.render()
          this.#syncURL()
        }
      },
      onRowSelectionChange: (updater) => {
        const next = typeof updater === "function" ? updater(this.tableState.rowSelection) : updater
        this.rowSelection = next
        this.tableState = { ...this.tableState, rowSelection: next }
        this.table.setOptions((p) => ({ ...p, state: this.tableState }))
        this.render()
      },
      onStateChange: (updater) => {
        const next = typeof updater === "function" ? updater(this.tableState) : updater
        this.tableState = next
        this.table.setOptions((p) => ({ ...p, state: this.tableState }))
        this.render()
      }
    }))

    if (this.hasSearchTarget && this.searchValue) {
      this.searchTarget.value = this.searchValue
    }

    this.render()
  }

  disconnect() {
    if (this.searchTimeout) clearTimeout(this.searchTimeout)
  }

  previousPage() { this.table.previousPage() }
  nextPage() { this.table.nextPage() }

  search() {
    if (this.searchTimeout) clearTimeout(this.searchTimeout)
    this.searchTimeout = setTimeout(() => {
      const query = this.searchTarget.value
      this.rowSelection = {}
      this.tableState = {
        ...this.tableState,
        globalFilter: query,
        pagination: { ...this.tableState.pagination, pageIndex: 0 },
        rowSelection: {}
      }
      this.table.setOptions((p) => ({ ...p, state: this.tableState }))
      this.#fetchAndRender()
    }, 300)
  }

  changePerPage() {
    const pageSize = parseInt(this.perPageTarget.value)
    this.rowSelection = {}
    this.tableState = {
      ...this.tableState,
      pagination: { pageIndex: 0, pageSize },
      rowSelection: {}
    }
    this.table.setOptions((p) => ({ ...p, state: this.tableState }))
    this.#fetchAndRender()
  }

  render() {
    this.#renderHeaders()
    this.#renderRows()
    this.#syncPaginationUI()
    this.#syncBulkActionsUI()
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
        this.#syncURL()
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
    if (this.tableState.globalFilter) {
      url.searchParams.set("search", this.tableState.globalFilter)
    }
    return url.toString()
  }

  #syncURL() {
    if (!this.hasSrcValue || !this.srcValue) return
    history.replaceState(null, "", this.#buildURL())
  }

  #syncPaginationUI() {
    if (this.hasPageIndicatorTarget) {
      const { pageIndex } = this.tableState.pagination
      this.pageIndicatorTarget.textContent = `Page ${pageIndex + 1} of ${this.table.getPageCount()}`
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

  #syncBulkActionsUI() {
    if (!this.hasBulkActionsTarget) return

    const selected = this.table.getSelectedRowModel().rows
    const count = selected.length
    const ids = selected.map((r) => r.id)

    if (count > 0) {
      this.bulkActionsTarget.classList.remove("hidden")
      this.bulkActionsTarget.classList.add("flex")
      this.bulkActionsTarget.dataset.selectedIds = JSON.stringify(ids)
      this.bulkActionsTarget.dataset.selectedCount = count

      const countEl = this.bulkActionsTarget.querySelector("[data-selection-count]")
      if (countEl) countEl.textContent = `${count} row${count === 1 ? "" : "s"} selected`
    } else {
      this.bulkActionsTarget.classList.add("hidden")
      this.bulkActionsTarget.classList.remove("flex")
      this.bulkActionsTarget.dataset.selectedIds = "[]"
      this.bulkActionsTarget.dataset.selectedCount = 0
    }

    // Dispatch custom event so consumers can react
    this.dispatch("selection-change", { detail: { count, ids } })
  }

  #renderHeaders() {
    if (!this.hasTheadTarget) return

    const html = this.table.getHeaderGroups().map((group) => {
      let cells = ""

      if (this.selectableValue) {
        const isAll = this.table.getIsAllPageRowsSelected()
        const isSome = this.table.getIsSomePageRowsSelected()
        cells += `<th class="h-10 w-10 px-2 align-middle">
          <input type="checkbox"
            class="h-4 w-4 rounded border border-input accent-primary cursor-pointer"
            ${isAll ? "checked" : ""}
            data-indeterminate="${isSome && !isAll}"
            data-action="change->ruby-ui--data-table#toggleAllRows"
          />
        </th>`
      }

      cells += group.headers.map((header) => {
        const def = header.column.columnDef.header
        const label = typeof def === "function" ? def(header.getContext()) : (def ?? "")
        const sorted = header.column.getIsSorted()
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

    // Wire sort buttons
    this.theadTarget.querySelectorAll("[data-sort-col]").forEach((btn) => {
      btn.addEventListener("click", () => {
        const col = this.table.getColumn(btn.dataset.sortCol)
        if (col) col.toggleSorting()
      })
    })

    // Wire indeterminate state on select-all checkbox
    if (this.selectableValue) {
      const cb = this.theadTarget.querySelector("input[type=checkbox]")
      if (cb) cb.indeterminate = cb.dataset.indeterminate === "true"
    }
  }

  toggleAllRows(event) {
    this.table.toggleAllPageRowsSelected(event.target.checked)
  }

  #renderRows() {
    if (!this.hasTbodyTarget) return

    const rows = this.table.getRowModel().rows
    if (rows.length === 0) {
      const colspan = this.columnsValue.length + (this.selectableValue ? 1 : 0)
      this.tbodyTarget.innerHTML = `<tr><td class="h-24 text-center text-muted-foreground" colspan="${colspan}">No results.</td></tr>`
      return
    }

    const html = rows.map((row) => {
      let cells = ""

      if (this.selectableValue) {
        const isSelected = row.getIsSelected()
        cells += `<td class="w-10 px-2 align-middle">
          <input type="checkbox"
            class="h-4 w-4 rounded border border-input accent-primary cursor-pointer"
            ${isSelected ? "checked" : ""}
            data-row-id="${row.id}"
            data-action="change->ruby-ui--data-table#toggleRow"
          />
        </td>`
      }

      cells += row.getVisibleCells().map((cell) => {
        const value = cell.getValue()
        const meta = cell.column.columnDef.meta ?? {}
        const type = meta.type ?? "text"
        const renderer = this.constructor.CELL_RENDERERS[type] ?? this.constructor.CELL_RENDERERS.text
        return `<td class="p-2 align-middle">${renderer(value, meta)}</td>`
      }).join("")

      const selectedClass = row.getIsSelected() ? "bg-muted/50" : ""
      return `<tr class="border-b transition-colors hover:bg-muted/50 ${selectedClass}">${cells}</tr>`
    }).join("")

    this.tbodyTarget.innerHTML = html
  }

  toggleRow(event) {
    const rowId = event.target.dataset.rowId
    const row = this.table.getRowModel().rows.find((r) => r.id === rowId)
    if (row) row.toggleSelected(event.target.checked)
  }

  static CELL_RENDERERS = {
    text: (value) => escapeHtml(value ?? ""),

    badge: (value, meta) => {
      const colors = meta?.colors ?? {}
      const colorClass = colors[value] ?? "bg-secondary text-secondary-foreground"
      return `<span class="inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ${colorClass}">${escapeHtml(value ?? "")}</span>`
    },

    date: (value) => {
      if (!value) return ""
      const d = new Date(value)
      return isNaN(d.getTime()) ? escapeHtml(value) : d.toLocaleDateString()
    },

    currency: (value) => {
      if (value == null || value === "") return ""
      return new Intl.NumberFormat("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 0 }).format(Number(value))
    }
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
