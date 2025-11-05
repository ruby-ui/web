import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="custom-tabs"
export default class extends Controller {
  setTab(event) {
    this.element.dataset.tab = event.detail.value;
  }
}

