import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { delay: { type: Number, default: 300 } };

  connect() {
    this.timer = null;
    this.restoreState = null;
    this.beforeFrameRender = this.captureBeforeRender.bind(this);
    this.afterFrameRender = this.applyAfterRender.bind(this);
    document.addEventListener("turbo:before-frame-render", this.beforeFrameRender);
    document.addEventListener("turbo:frame-render", this.afterFrameRender);
  }

  disconnect() {
    clearTimeout(this.timer);
    document.removeEventListener("turbo:before-frame-render", this.beforeFrameRender);
    document.removeEventListener("turbo:frame-render", this.afterFrameRender);
  }

  submit(event) {
    if (event && event.type !== "input") return;
    clearTimeout(this.timer);
    if (this.delayValue <= 0) return;
    this.timer = setTimeout(() => this.element.requestSubmit(), this.delayValue);
  }

  captureBeforeRender() {
    const input = this.input();
    if (!input || document.activeElement !== input) {
      this.restoreState = null;
      return;
    }
    this.restoreState = {
      selectionStart: input.selectionStart,
      selectionEnd: input.selectionEnd
    };
  }

  applyAfterRender() {
    if (!this.restoreState) return;
    const state = this.restoreState;
    this.restoreState = null;
    const input = this.input();
    if (!input) return;
    input.focus();
    const len = input.value.length;
    try {
      input.setSelectionRange(
        Math.min(state.selectionStart ?? len, len),
        Math.min(state.selectionEnd ?? len, len)
      );
    } catch (e) {}
  }

  input() {
    return this.element.querySelector('input[type="search"]');
  }
}
