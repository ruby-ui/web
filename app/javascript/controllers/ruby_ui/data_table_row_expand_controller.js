import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  toggle(event) {
    const button = event.currentTarget;
    const id = button.getAttribute("aria-controls");
    if (!id) return;
    const target = document.getElementById(id);
    if (!target) return;
    const expanded = button.getAttribute("aria-expanded") === "true";
    button.setAttribute("aria-expanded", String(!expanded));
    target.classList.toggle("hidden", expanded);
  }
}
