import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { delay: { type: Number, default: 300 } };

  connect() {
    this.timer = null;
  }

  submit(event) {
    // Only react to input events (not submit/change).
    if (event && event.type !== "input") return;
    clearTimeout(this.timer);
    if (this.delayValue <= 0) return;
    this.timer = setTimeout(() => {
      this.element.requestSubmit();
    }, this.delayValue);
  }

  disconnect() {
    clearTimeout(this.timer);
  }
}
