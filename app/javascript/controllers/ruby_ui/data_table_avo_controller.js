import { Controller } from "@hotwired/stimulus";

// Handles client-side UX for DataTableAvo: row selection, column visibility,
// and dropdown open/close. Row/column state is ephemeral — it resets on any
// Turbo Frame navigation (sort/page/search), since the table is re-rendered
// fresh from the server. That's by design and matches the Avo philosophy.
export default class extends Controller {
  static targets = [
    "selectAll",
    "rowCheckbox",
    "selectionSummary",
    "columnsMenu",
    "columnToggle",
  ];

  connect() {
    this.refreshSelectionSummary();
    this.closeColumnsMenuBound = this.closeColumnsMenuOnOutside.bind(this);
  }

  toggleAll(event) {
    const checked = event.target.checked;
    this.rowCheckboxTargets.forEach((cb) => {
      cb.checked = checked;
    });
    this.refreshSelectionSummary();
  }

  toggleRow() {
    if (this.hasSelectAllTarget) {
      const all = this.rowCheckboxTargets.length;
      const sel = this.selectedRowCheckboxes.length;
      this.selectAllTarget.checked = all > 0 && sel === all;
      this.selectAllTarget.indeterminate = sel > 0 && sel < all;
    }
    this.refreshSelectionSummary();
  }

  toggleColumnsMenu(event) {
    event.stopPropagation();
    if (!this.hasColumnsMenuTarget) return;
    const menu = this.columnsMenuTarget;
    const isHidden = menu.classList.toggle("hidden");
    if (!isHidden) {
      document.addEventListener("click", this.closeColumnsMenuBound);
    } else {
      document.removeEventListener("click", this.closeColumnsMenuBound);
    }
  }

  closeColumnsMenuOnOutside(event) {
    if (!this.hasColumnsMenuTarget) return;
    if (!this.element.contains(event.target)) {
      this.columnsMenuTarget.classList.add("hidden");
      document.removeEventListener("click", this.closeColumnsMenuBound);
    }
  }

  toggleColumnVisibility(event) {
    const key = event.target.dataset.columnKey;
    const visible = event.target.checked;
    this.element
      .querySelectorAll(`[data-column="${key}"]`)
      .forEach((el) => el.classList.toggle("hidden", !visible));
  }

  get selectedRowCheckboxes() {
    return this.rowCheckboxTargets.filter((cb) => cb.checked);
  }

  refreshSelectionSummary() {
    if (!this.hasSelectionSummaryTarget) return;
    const total = this.rowCheckboxTargets.length;
    const sel = this.selectedRowCheckboxes.length;
    this.selectionSummaryTarget.textContent = `${sel} of ${total} row(s) selected.`;
  }
}
