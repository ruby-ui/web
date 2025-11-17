import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileButton", "fileHeader", "fileContent"]

  selectFile(event) {
    const selectedPath = event.currentTarget.dataset.filePath

    // Update button states
    this.fileButtonTargets.forEach(button => {
      const isSelected = button.dataset.filePath === selectedPath
      button.dataset.active = isSelected.toString()
      button.classList.toggle("bg-accent", isSelected)
      button.classList.toggle("text-accent-foreground", isSelected)
      button.classList.toggle("text-muted-foreground", !isSelected)
    })

    // Update file headers
    this.fileHeaderTargets.forEach(header => {
      const isSelected = header.dataset.filePath === selectedPath
      header.classList.toggle("hidden", !isSelected)
    })

    // Update file contents
    this.fileContentTargets.forEach(content => {
      const isSelected = content.dataset.filePath === selectedPath
      content.classList.toggle("hidden", !isSelected)
    })
  }
}


