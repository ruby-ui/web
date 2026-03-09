import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="nested-sidebar"
// Switches content panels when icon rail buttons are clicked
export default class extends Controller {
  static targets = ["icon", "panel"]
  static values = { active: String }

  select(event) {
    this.activeValue = event.currentTarget.dataset.section
  }

  activeValueChanged() {
    this.iconTargets.forEach((icon) => {
      const isActive = icon.dataset.section === this.activeValue
      icon.dataset.active = isActive
    })

    this.panelTargets.forEach((panel) => {
      panel.hidden = panel.dataset.section !== this.activeValue
    })
  }
}
