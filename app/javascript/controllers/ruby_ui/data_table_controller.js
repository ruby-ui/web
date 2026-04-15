import { Controller } from "@hotwired/stimulus";
import {
  createTable,
  getCoreRowModel,
  getSortedRowModel,
} from "@tanstack/table-core";

export default class extends Controller {
  static targets = [
    "thead",
    "tbody",
    "prevButton",
    "nextButton",
    "pageIndicator",
    "search",
    "perPage",
    "bulkActions",
    "columnToggleTrigger",
    "columnMenu",
    "tplSortAsc",
    "tplSortDesc",
    "tplSortNone",
    "tplCheckbox",
    "tplChevron",
    "tplExpandedRow",
  ];
  static values = {
    src: String,
    data: { type: Array, default: [] },
    columns: { type: Array, default: [] },
    rowCount: { type: Number, default: 0 },
    pagination: { type: Object, default: { pageIndex: 0, pageSize: 10 } },
    sorting: { type: Array, default: [] },
    search: { type: String, default: "" },
    selectable: { type: Boolean, default: false },
    syncUrl: { type: Boolean, default: true },
    columnVisibility: { type: Object, default: {} },
    options: { type: Object, default: {} },
  };

  connect() {
    this.searchTimeout = null;
    this.rowSelection = {};

    this.hasServer = this.hasSrcValue && !!this.srcValue;

    const columnDefs = this.columnsValue.map((c) => ({
      id: c.key,
      accessorKey: c.key,
      header: c.header,
    }));

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
      // Spread any user-provided TanStack options (enableExpanding, etc.)
      ...this.optionsValue,
      state: {},
      onStateChange: () => {},
    });

    this.expandable = this.hasTplExpandedRowTarget || this.optionsValue.enableExpanding === true;

    this.tableState = {
      ...this.table.initialState,
      pagination: this.paginationValue,
      sorting: this.sortingValue,
      globalFilter: this.searchValue,
      rowSelection: this.rowSelection,
      columnVisibility: this.columnVisibilityValue,
      expanded: {},
    };

    this.table.setOptions((prev) => ({
      ...prev,
      state: this.tableState,
      onPaginationChange: (updater) => {
        const next =
          typeof updater === "function"
            ? updater(this.tableState.pagination)
            : updater;
        this.rowSelection = {};
        this.tableState = {
          ...this.tableState,
          pagination: next,
          rowSelection: {},
        };
        this.table.setOptions((p) => ({ ...p, state: this.tableState }));
        this.#fetchAndRender();
      },
      onSortingChange: (updater) => {
        const next =
          typeof updater === "function"
            ? updater(this.tableState.sorting)
            : updater;
        this.rowSelection = {};
        this.tableState = {
          ...this.tableState,
          sorting: next,
          pagination: { ...this.tableState.pagination, pageIndex: 0 },
          rowSelection: {},
        };
        this.table.setOptions((p) => ({ ...p, state: this.tableState }));
        if (this.hasServer) {
          this.#fetchAndRender();
        } else {
          this.render();
          this.#syncURL();
        }
      },
      onRowSelectionChange: (updater) => {
        const next =
          typeof updater === "function"
            ? updater(this.tableState.rowSelection)
            : updater;
        this.rowSelection = next;
        this.tableState = { ...this.tableState, rowSelection: next };
        this.table.setOptions((p) => ({ ...p, state: this.tableState }));
        this.render();
      },
      onColumnVisibilityChange: (updater) => {
        const next =
          typeof updater === "function"
            ? updater(this.tableState.columnVisibility)
            : updater;
        this.tableState = { ...this.tableState, columnVisibility: next };
        this.table.setOptions((p) => ({ ...p, state: this.tableState }));
        this.render();
      },
      onExpandedChange: (updater) => {
        const next =
          typeof updater === "function"
            ? updater(this.tableState.expanded)
            : updater;
        this.tableState = { ...this.tableState, expanded: next };
        this.table.setOptions((p) => ({ ...p, state: this.tableState }));
        this.render();
      },
      onStateChange: (updater) => {
        const next =
          typeof updater === "function" ? updater(this.tableState) : updater;
        this.tableState = next;
        this.table.setOptions((p) => ({ ...p, state: this.tableState }));
        this.render();
      },
    }));

    if (this.hasSearchTarget && this.searchValue) {
      this.searchTarget.value = this.searchValue;
    }

    this.render();
  }

  disconnect() {
    if (this.searchTimeout) clearTimeout(this.searchTimeout);
  }

  previousPage() {
    this.table.previousPage();
  }
  nextPage() {
    this.table.nextPage();
  }

  search() {
    if (this.searchTimeout) clearTimeout(this.searchTimeout);
    this.searchTimeout = setTimeout(() => {
      const query = this.searchTarget.value;
      this.rowSelection = {};
      this.tableState = {
        ...this.tableState,
        globalFilter: query,
        pagination: { ...this.tableState.pagination, pageIndex: 0 },
        rowSelection: {},
      };
      this.table.setOptions((p) => ({ ...p, state: this.tableState }));
      this.#fetchAndRender();
    }, 300);
  }

  changePerPage() {
    const pageSize = parseInt(this.perPageTarget.value);
    this.rowSelection = {};
    this.tableState = {
      ...this.tableState,
      pagination: { pageIndex: 0, pageSize },
      rowSelection: {},
    };
    this.table.setOptions((p) => ({ ...p, state: this.tableState }));
    this.#fetchAndRender();
  }

  render() {
    this.#renderHeaders();
    this.#renderRows();
    this.#syncPaginationUI();
    this.#syncBulkActionsUI();
    this.#renderColumnMenu();
  }

  toggleColumnMenu(event) {
    event.stopPropagation();
    if (!this.hasColumnMenuTarget) return;
    const menu = this.columnMenuTarget;
    menu.classList.toggle("hidden");

    if (!menu.classList.contains("hidden")) {
      this._closeColumnMenuOnOutsideClick = (e) => {
        if (!this.element.contains(e.target)) {
          menu.classList.add("hidden");
          document.removeEventListener("click", this._closeColumnMenuOnOutsideClick);
        }
      };
      document.addEventListener("click", this._closeColumnMenuOnOutsideClick);
    }
  }

  toggleColumnVisibility(event) {
    const col = this.table.getColumn(event.target.dataset.colId);
    if (col) col.toggleVisibility(event.target.checked);
  }

  toggleRowExpansion(event) {
    const rowId = event.currentTarget.dataset.rowId;
    const row = this.table.getRowModel().rows.find((r) => r.id === rowId);
    if (row) row.toggleExpanded();
  }

  #fetchAndRender() {
    if (!this.hasSrcValue || !this.srcValue) return;
    fetch(this.#buildURL(), { headers: { Accept: "application/json" } })
      .then((r) => r.json())
      .then(({ data, row_count }) => {
        this.table.setOptions((prev) => ({
          ...prev,
          data,
          rowCount: row_count,
          state: this.tableState,
        }));
        this.render();
        this.#syncURL();
      });
  }

  #buildURL() {
    const url = new URL(this.srcValue, window.location.origin);
    const { pageIndex, pageSize } = this.tableState.pagination;
    url.searchParams.set("page", pageIndex + 1);
    url.searchParams.set("per_page", pageSize);
    if (this.tableState.sorting.length > 0) {
      const { id, desc } = this.tableState.sorting[0];
      url.searchParams.set("sort", id);
      url.searchParams.set("direction", desc ? "desc" : "asc");
    }
    if (this.tableState.globalFilter) {
      url.searchParams.set("search", this.tableState.globalFilter);
    }
    return url.toString();
  }

  #syncURL() {
    if (!this.hasSrcValue || !this.srcValue) return;
    if (!this.syncUrlValue) return;
    history.replaceState(null, "", this.#buildURL());
  }

  #syncPaginationUI() {
    if (this.hasPageIndicatorTarget) {
      const { pageIndex } = this.tableState.pagination;
      this.pageIndicatorTarget.textContent = `Page ${pageIndex + 1} of ${this.table.getPageCount()}`;
    }
    if (this.hasPrevButtonTarget) {
      const can = this.table.getCanPreviousPage();
      this.prevButtonTarget.disabled = !can;
      this.prevButtonTarget.classList.toggle("opacity-50", !can);
      this.prevButtonTarget.classList.toggle("pointer-events-none", !can);
    }
    if (this.hasNextButtonTarget) {
      const can = this.table.getCanNextPage();
      this.nextButtonTarget.disabled = !can;
      this.nextButtonTarget.classList.toggle("opacity-50", !can);
      this.nextButtonTarget.classList.toggle("pointer-events-none", !can);
    }
  }

  #renderColumnMenu() {
    if (!this.hasColumnMenuTarget) return;

    const columns = this.table
      .getAllLeafColumns()
      .filter((col) => col.getCanHide());

    const fragment = document.createDocumentFragment();

    columns.forEach((col) => {
      const label = document.createElement("label");
      label.className = "flex items-center gap-2 rounded-sm px-2 py-1.5 text-sm cursor-pointer hover:bg-accent";

      const cb = this.#cloneTemplate("tplCheckbox")?.firstElementChild
        || Object.assign(document.createElement("input"), { type: "checkbox" });
      cb.checked = col.getIsVisible();
      cb.dataset.colId = col.id;
      cb.dataset.action = "change->ruby-ui--data-table#toggleColumnVisibility";
      label.appendChild(cb);

      const span = document.createElement("span");
      const def = col.columnDef.header;
      span.textContent = typeof def === "function" ? col.id : (def ?? col.id);
      label.appendChild(span);

      fragment.appendChild(label);
    });

    this.columnMenuTarget.replaceChildren(fragment);
  }

  #syncBulkActionsUI() {
    if (!this.hasBulkActionsTarget) return;

    const selected = this.table.getSelectedRowModel().rows;
    const count = selected.length;
    const ids = selected.map((r) => r.id);

    if (count > 0) {
      this.bulkActionsTarget.classList.remove("hidden");
      this.bulkActionsTarget.classList.add("flex");
      this.bulkActionsTarget.dataset.selectedIds = JSON.stringify(ids);
      this.bulkActionsTarget.dataset.selectedCount = count;

      const countEl = this.bulkActionsTarget.querySelector(
        "[data-selection-count]",
      );
      if (countEl)
        countEl.textContent = `${count} row${count === 1 ? "" : "s"} selected`;
    } else {
      this.bulkActionsTarget.classList.add("hidden");
      this.bulkActionsTarget.classList.remove("flex");
      this.bulkActionsTarget.dataset.selectedIds = "[]";
      this.bulkActionsTarget.dataset.selectedCount = 0;
    }

    // Dispatch custom event so consumers can react
    this.dispatch("selection-change", { detail: { count, ids } });
  }

  // Clone a <template> target into a live DOM node
  #cloneTemplate(targetName) {
    const tpl = this[`${targetName}Target`];
    return tpl ? tpl.content.cloneNode(true) : null;
  }

  #sortIcon(sorted) {
    const name = sorted === "asc" ? "tplSortAsc" : sorted === "desc" ? "tplSortDesc" : "tplSortNone";
    return this[`has${name.charAt(0).toUpperCase() + name.slice(1)}Target`]
      ? this.#cloneTemplate(name)
      : null;
  }

  #renderHeaders() {
    if (!this.hasTheadTarget) return;

    const fragment = document.createDocumentFragment();

    this.table.getHeaderGroups().forEach((group) => {
      const tr = document.createElement("tr");
      tr.className = "border-b transition-colors";

      if (this.expandable) {
        const th = document.createElement("th");
        th.className = "h-10 w-10 px-2 align-middle";
        tr.appendChild(th);
      }

      if (this.selectableValue) {
        const th = document.createElement("th");
        th.className = "h-10 w-10 px-2 align-middle";

        const cb = this.#cloneTemplate("tplCheckbox")?.firstElementChild
          || Object.assign(document.createElement("input"), { type: "checkbox" });
        cb.checked = this.table.getIsAllPageRowsSelected();
        cb.indeterminate = this.table.getIsSomePageRowsSelected() && !cb.checked;
        cb.dataset.action = "change->ruby-ui--data-table#toggleAllRows";
        th.appendChild(cb);
        tr.appendChild(th);
      }

      group.headers.forEach((header) => {
        const def = header.column.columnDef.header;
        const label = typeof def === "function" ? def(header.getContext()) : (def ?? "");
        const th = document.createElement("th");
        th.className = "h-10 px-2 text-left align-middle font-medium text-muted-foreground";

        if (header.column.getCanSort()) {
          const btn = document.createElement("button");
          btn.className = "flex items-center gap-1 hover:text-foreground transition-colors";
          btn.dataset.sortCol = header.column.id;
          btn.appendChild(document.createTextNode(label));

          const icon = this.#sortIcon(header.column.getIsSorted());
          if (icon) btn.appendChild(icon);

          btn.addEventListener("click", () => header.column.toggleSorting());
          th.appendChild(btn);
        } else {
          th.textContent = label;
        }

        tr.appendChild(th);
      });

      fragment.appendChild(tr);
    });

    this.theadTarget.replaceChildren(fragment);
  }

  toggleAllRows(event) {
    this.table.toggleAllPageRowsSelected(event.target.checked);
  }

  #renderRows() {
    if (!this.hasTbodyTarget) return;

    const rows = this.table.getRowModel().rows;

    const extraCols = (this.selectableValue ? 1 : 0) + (this.expandable ? 1 : 0);

    if (rows.length === 0) {
      const tr = document.createElement("tr");
      const td = document.createElement("td");
      td.className = "h-24 text-center text-muted-foreground";
      td.colSpan = this.columnsValue.length + extraCols;
      td.textContent = "No results.";
      tr.appendChild(td);
      this.tbodyTarget.replaceChildren(tr);
      return;
    }

    const fragment = document.createDocumentFragment();

    rows.forEach((row) => {
      const tr = document.createElement("tr");
      tr.className = `border-b transition-colors hover:bg-muted/50${row.getIsSelected() ? " bg-muted/50" : ""}`;

      if (this.expandable) {
        const td = document.createElement("td");
        td.className = "w-10 px-2 align-middle";
        const btn = document.createElement("button");
        btn.type = "button";
        btn.className = "inline-flex items-center justify-center rounded-md h-6 w-6 hover:bg-accent hover:text-accent-foreground";
        btn.dataset.rowId = row.id;
        btn.dataset.action = "click->ruby-ui--data-table#toggleRowExpansion";
        btn.setAttribute("aria-label", row.getIsExpanded() ? "Collapse row" : "Expand row");

        const chevron = this.#cloneTemplate("tplChevron");
        if (chevron) {
          const svg = chevron.firstElementChild;
          if (row.getIsExpanded()) svg.classList.add("rotate-90");
          btn.appendChild(chevron);
        }
        td.appendChild(btn);
        tr.appendChild(td);
      }

      if (this.selectableValue) {
        const td = document.createElement("td");
        td.className = "w-10 px-2 align-middle";

        const cb = this.#cloneTemplate("tplCheckbox")?.firstElementChild
          || Object.assign(document.createElement("input"), { type: "checkbox" });
        cb.checked = row.getIsSelected();
        cb.dataset.rowId = row.id;
        cb.dataset.action = "change->ruby-ui--data-table#toggleRow";
        td.appendChild(cb);
        tr.appendChild(td);
      }

      row.getVisibleCells().forEach((cell) => {
        const td = document.createElement("td");
        td.className = "p-2 align-middle";
        this.#renderCell(td, cell.column.id, cell.getValue(), row);
        tr.appendChild(td);
      });

      fragment.appendChild(tr);

      if (this.expandable && row.getIsExpanded() && this.hasTplExpandedRowTarget) {
        const expandedTr = document.createElement("tr");
        expandedTr.className = "border-b bg-muted/30";

        const expandedTd = document.createElement("td");
        expandedTd.colSpan = this.columnsValue.length + extraCols;
        expandedTd.className = "p-0";

        const content = this.tplExpandedRowTarget.content.cloneNode(true);
        // Populate any [data-field="columnKey"] elements via the column's
        // registered cell template (if any) or fall back to plain text.
        content.querySelectorAll("[data-field]").forEach((el) => {
          const key = el.dataset.field;
          const value = row.original?.[key];
          this.#renderCell(el, key, value, row);
        });

        expandedTd.appendChild(content);
        expandedTr.appendChild(expandedTd);
        fragment.appendChild(expandedTr);
      }
    });

    this.tbodyTarget.replaceChildren(fragment);
  }

  toggleRow(event) {
    const rowId = event.target.dataset.rowId;
    const row = this.table.getRowModel().rows.find((r) => r.id === rowId);
    if (row) row.toggleSelected(event.target.checked);
  }

  // Cell rendering: look up the Phlex-authored <template> for this column,
  // clone it, populate [data-field] elements, then apply browser-native
  // formatters keyed by data-cell-format. All markup lives in Ruby; this
  // method only formats primitives and swaps DOM nodes.
  //
  // `el` is the <td> to populate, `colId` is the column key, `value` is the
  // raw cell value, `row` is the TanStack row object.
  #renderCell(el, colId, value, row) {
    // Look up <template data-ruby-ui--data-table-target="tplCell_<colId>">
    // by selector (colId values are dynamic — can't list all targets upfront).
    const tpl = this.element.querySelector(
      `template[data-ruby-ui--data-table-target="tplCell_${CSS.escape(colId)}"]`
    );

    if (!tpl || !tpl.content) {
      // Fallback: plain text
      el.textContent = value == null ? "" : String(value);
      return;
    }

    const content = tpl.content.cloneNode(true);
    const format = tpl.dataset.cellFormat;
    const locale = tpl.dataset.cellLocale || "en-US";

    content.querySelectorAll("[data-field]").forEach((placeholder) => {
      const formatted = this.#formatCellValue(value, format, tpl, locale, row);

      if (placeholder.dataset.applyColors != null) {
        // Badge: set text + apply colors-map classes
        placeholder.textContent = value == null ? "" : String(value);
        const colors = tpl.dataset.cellColors ? JSON.parse(tpl.dataset.cellColors) : {};
        const fallback = tpl.dataset.cellFallbackClasses;
        const classStr = colors[value] ?? fallback;
        if (classStr) placeholder.classList.add(...classStr.split(/\s+/).filter(Boolean));
      } else if (placeholder.dataset.applyHref != null) {
        // Link: fill href with {value} substitution, set text if no fixed label
        const hrefTemplate = tpl.dataset.cellHrefTemplate || "{value}";
        placeholder.setAttribute(
          "href",
          hrefTemplate.replaceAll("{value}", encodeURIComponent(value ?? ""))
        );
        if (!placeholder.textContent.trim()) {
          placeholder.textContent = formatted;
        }
      } else if (placeholder.dataset.applyTitle != null) {
        // Truncate: set full value as title, show truncated text
        placeholder.title = value == null ? "" : String(value);
        placeholder.textContent = formatted;
      } else {
        placeholder.textContent = formatted;
      }
    });

    el.replaceChildren(content);
  }

  #formatCellValue(value, format, tpl, locale, row) {
    if (value == null || value === "") return "";

    switch (format) {
      case "currency": {
        const currency = tpl.dataset.cellCurrency || "USD";
        const digits = Number(tpl.dataset.cellDigits ?? 0);
        return new Intl.NumberFormat(locale, {
          style: "currency",
          currency,
          maximumFractionDigits: digits,
          minimumFractionDigits: digits,
        }).format(Number(value));
      }
      case "number":
        return new Intl.NumberFormat(locale).format(Number(value));
      case "percent": {
        const digits = Number(tpl.dataset.cellDigits ?? 0);
        return new Intl.NumberFormat(locale, {
          style: "percent",
          minimumFractionDigits: digits,
          maximumFractionDigits: digits,
        }).format(Number(value));
      }
      case "date": {
        const d = new Date(value);
        return isNaN(d.getTime()) ? String(value) : d.toLocaleDateString(locale);
      }
      case "boolean":
        if (value === true) return "✓";
        if (value === false) return "—";
        return "";
      case "truncate": {
        const max = Number(tpl.dataset.cellMax ?? 40);
        const str = String(value);
        return str.length > max ? str.slice(0, max - 1) + "…" : str;
      }
      default:
        return String(value);
    }
  }
}

function escapeHtml(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}
