import { Controller } from "@hotwired/stimulus";

const FLAG_KEY = "ruby-ui--data-table-search-focus";

export default class extends Controller {
  static values = { delay: { type: Number, default: 300 } };

  connect() {
    this.timer = null;
    this.restoreFocus();
  }

  disconnect() {
    clearTimeout(this.timer);
  }

  submit(event) {
    if (event && event.type !== "input") return;
    clearTimeout(this.timer);
    if (this.delayValue <= 0) return;
    this.timer = setTimeout(() => this.submitNow(), this.delayValue);
  }

  submitNow() {
    const input = this.input();
    if (input && document.activeElement === input) {
      try {
        sessionStorage.setItem(
          this.flagKey(),
          JSON.stringify({
            selectionStart: input.selectionStart,
            selectionEnd: input.selectionEnd,
          })
        );
      } catch (e) {}
    }
    this.element.requestSubmit();
  }

  restoreFocus() {
    let state;
    try {
      const raw = sessionStorage.getItem(this.flagKey());
      if (!raw) return;
      sessionStorage.removeItem(this.flagKey());
      state = JSON.parse(raw);
    } catch (e) {
      return;
    }
    const input = this.input();
    if (!input) return;
    input.focus();
    const len = input.value.length;
    const start = Math.min(state.selectionStart ?? len, len);
    const end = Math.min(state.selectionEnd ?? len, len);
    try {
      input.setSelectionRange(start, end);
    } catch (e) {}
  }

  input() {
    return this.element.querySelector('input[type="search"]');
  }

  flagKey() {
    // Scope flag by form action so multiple tables on one page don't collide.
    return `${FLAG_KEY}:${this.element.action || "_"}`;
  }
}
