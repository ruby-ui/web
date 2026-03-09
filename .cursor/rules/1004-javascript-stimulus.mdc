---
description: Follow JavaScript and Stimulus controller standards when creating or modifying JS files
globs: ["app/javascript/**/*.js"]
---

# JavaScript and Stimulus Controller Standards

## Context

- In Ruby on Rails 8.0 JavaScript
- Using Stimulus.js for interactive components
- Using ES6 features
- Using TailwindCSS Stimulus Components

## Requirements

- Use ES6 syntax (arrow functions, destructuring, etc.)
- Add comments at the top of Stimulus controllers explaining their purpose and usage examples
- Follow Stimulus controller naming conventions
- Use data-controller, data-action, and data-[controller]-target attributes
- Define static targets, values, and classes at the top of controller classes
- Initialize connections in the connect() lifecycle method
- Clean up resources in the disconnect() lifecycle method
- Use the tailwindcss-stimulus-components library for common components:
  - Alert, Dropdown, Modal, Tabs, Popover, Toggle, Slideover
- Keep controller actions focused on a single responsibility
- Use event delegation where appropriate
- Document values properties with their types and defaults
- Avoid DOM manipulation where possible, prefer toggling classes

## Examples

<example>
```javascript
// Example usage:
// <div data-controller="tooltip" data-tooltip-content-value="Hello world"></div>

import { Controller } from "@hotwired/stimulus" import { autoUpdate, autoPlacement, computePosition, offset, arrow } from "@floating-ui/dom"

export default class extends Controller { // Define expected properties and their types static values = { content: String, placement: String, offset: { type: Number, default: 6 }, allowHtml: { type: Boolean, default: true } }

// Initialize on connection connect() { this.createTooltipElements() this.cleanup = autoUpdate(this.element, this.tooltip, this.updatePosition.bind(this)) this.addEvents() }

// Clean up resources on disconnect disconnect() { this.removeEvents() this.tooltip?.remove() this.cleanup?.() }

// Creates DOM elements for the tooltip createTooltipElements() { this.tooltip = document.createElement("div") this.tooltip.className = "tooltip" this.tooltip.setAttribute("role", "tooltip")

    this.tooltipContent = document.createElement("div")
    this.tooltipContent.className = "tooltip-content"

    this.tooltipArrow = document.createElement("div")
    this.tooltipArrow.className = "tooltip-arrow"

    this.tooltip.appendChild(this.tooltipContent)
    this.tooltip.appendChild(this.tooltipArrow)
    document.body.appendChild(this.tooltip)

    this.updateContent()

}

// Updates tooltip content when content value changes contentValueChanged() { this.updateContent() } }

````
</example>

<example type="invalid">
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    var self = this
    var tooltip = document.createElement("div")
    tooltip.className = "tooltip"
    tooltip.innerHTML = this.data.get("content")
    document.body.appendChild(tooltip)

    this.element.addEventListener("mouseenter", function() {
      tooltip.style.display = "block"
    })

    this.element.addEventListener("mouseleave", function() {
      tooltip.style.display = "none"
    })
  }
}
````

</example>
