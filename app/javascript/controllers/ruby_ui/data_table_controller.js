import { Controller } from "@hotwired/stimulus"
import { createTable, getCoreRowModel } from "@tanstack/table-core"

export default class extends Controller {
  static targets = ["thead", "tbody"]
  static values = {
    src: String,
    data: { type: Array, default: [] },
    columns: { type: Array, default: [] },
    rowCount: { type: Number, default: 0 }
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
      state: {},
      onStateChange: () => {},
      renderFallbackValue: null
    })

    this.render()
  }

  render() {
    this.renderHeaders()
    this.renderRows()
  }

  renderHeaders() {
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

  renderRows() {
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
