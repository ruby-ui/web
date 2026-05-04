import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ruby-ui--calendar-input"
export default class extends Controller {
  static outlets = ["ruby-ui--calendar"]
  static values = {
    format: { type: String, default: "MM-dd-yyyy" },
    placeholder: { type: String, default: "" },
    labelAnimation: { type: Boolean, default: false },
    labelClasses: { type: String, default: "" },
    labelSeparator: { type: String, default: "" }
  }

  connect() {
    this.isProgrammaticUpdate = false
    this.cacheLabel()
    if (!this.element.placeholder && this.placeholderValue) this.element.placeholder = this.placeholderValue
    this.addEventListeners()
  }

  disconnect() {
    this.removeEventListeners()
  }

  addEventListeners() {
    this.boundHandleInput = this.handleInput.bind(this)
    this.element.addEventListener("input", this.boundHandleInput)
  }

  removeEventListeners() {
    if (this.boundHandleInput) {
      this.element.removeEventListener("input", this.boundHandleInput)
    }
  }

  handleInput(event) {
    if (this.isProgrammaticUpdate) return
    const value = event.target.value
    if (this.matchesFormat(value)) {
      const oldValue = this.element.value
      this.syncCalendar(value)
      this.dispatchDateChange(oldValue, value)
    }
    if (this.labelEl) this.updateFloatingLabel(value)
  }

  syncCalendar(inputValue) {
    if (this.rubyUiCalendarOutlets.length === 0) return
    if (!this.matchesFormat(inputValue)) return
    const date = this.parseDate(inputValue)
    if (!this.isValidDate(date)) return

    const iso = this.toISOString(inputValue)
    this.rubyUiCalendarOutlets.forEach((outlet) => {
      if (outlet.selectedDateValue === iso) return
      outlet.selectedDateValue = iso
    })
  }

  matchesFormat(value) {
    return /^\d{2}-\d{2}-\d{4}$/.test(value)
  }

  parseDate(value) {
    const m = value.match(/^(\d{2})-(\d{2})-(\d{4})$/)
    if (!m) return null
    
    const [part1, part2, yearStr] = m.slice(1)
    const year = parseInt(yearStr, 10)
    const isAmericanFormat = this.formatValue === "MM-dd-yyyy"
    const month = parseInt(isAmericanFormat ? part1 : part2, 10)
    const day = parseInt(isAmericanFormat ? part2 : part1, 10)
    
    if (!this.#validateDateComponents(month, day, year)) return null
    
    return new Date(year, month - 1, day)
  }

  #validateDateComponents(month, day, year) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return false
    if (day > new Date(year, month, 0).getDate()) return false
    return true
  }

  toISOString(value) {
    const m = value.match(/^(\d{2})-(\d{2})-(\d{4})$/)
    if (!m) return null
    
    const part1 = m[1]
    const part2 = m[2]
    const year = m[3]
    
    if (this.formatValue === "MM-dd-yyyy") {
      return `${year}-${part1}-${part2}`
    } else {
      return `${year}-${part2}-${part1}`
    }
  }

  isValidDate(date) {
    return date instanceof Date && !isNaN(date.getTime())
  }

  cacheLabel() {
    this.labelEl = this.element.previousElementSibling
    if (this.labelEl?.tagName === "LABEL") {
      const separator = this.labelSeparatorValue || " "
      this.labelBaseText = this.labelEl.textContent.split(separator)[0].trim()
    } else {
      this.labelBaseText = null
    }
  }

  updateFloatingLabel(inputValue) {
    if (!this.labelEl || !this.labelBaseText) return
    if (!this.labelAnimationValue) return
    
    if (inputValue && inputValue.length > 0) {
      const separator = this.labelSeparatorValue || " "
      this.labelEl.textContent = `${this.labelBaseText}${separator}${this.placeholderValue}`
      this.addLabelClasses()
    } else {
      this.labelEl.textContent = this.labelBaseText
      this.removeLabelClasses()
    }
  }

  addLabelClasses() {
    if (!this.labelClassesValue) return
    this.labelEl.classList.add(...this.labelClassesValue.split(' '))
  }

  removeLabelClasses() {
    if (!this.labelClassesValue) return
    this.labelEl.classList.remove(...this.labelClassesValue.split(' '))
  }

  setValue(value) {
    this.isProgrammaticUpdate = true
    const formattedValue = (this.formatValue && this.formatValue !== "MM-dd-yyyy") ? this.formatDateForInput(value) : value
    this.element.value = formattedValue
    if (this.labelEl) this.updateFloatingLabel(formattedValue)
    requestAnimationFrame(() => { this.isProgrammaticUpdate = false })
  }

  formatDateForInput(dateString) {
    const match = dateString.match(/^(\d{4})-(\d{2})-(\d{2})$/)
    if (!match) return dateString
    
    const [, year, month, day] = match
    
    if (this.formatValue === "MM-dd-yyyy") {
      return `${month}-${day}-${year}`
    } else {
      return `${day}-${month}-${year}`
    }
  }

  dispatchDateChange(oldValue, newValue) {
    if (oldValue === newValue) return

    const event = new CustomEvent("date:changed", {
      detail: { oldValue, newValue, format: this.formatValue },
      bubbles: true,
      cancelable: true,
    })

    this.element.dispatchEvent(event)
  }
}
