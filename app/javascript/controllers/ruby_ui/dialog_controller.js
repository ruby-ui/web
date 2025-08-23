import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dialog"
export default class extends Controller {
  static targets = ["modal", "content", "backdrop"]
  static values = {
    open: {
      type: Boolean,
      default: false
    },
  }

  connect() {
    if (this.openValue) this.open()
  }

  open(e) {
    // if (e) e.preventDefault()
    this.modalTarget.showModal()

    this.backdropTarget.setAttribute('data-state', 'open')
    this.contentTarget.setAttribute('data-state', 'open')
  }

  dismiss() {
    // allow scroll on body
    const content = this.contentTarget.querySelector('div[data-state]')
    const backdrop = this.contentTarget.querySelector('div[data-action*="dismiss"]')
    if (content) content.setAttribute('data-state', 'closing')
    this.backdropTarget.setAttribute('data-state', 'closing')
    this.contentTarget.setAttribute('data-state', 'closing')


    Promise.all(
      this.contentTarget.getAnimations().map((animation) => animation.finished),
      this.backdropTarget.getAnimations().map((animation) => animation.finished),
    ).then(() => {
      this.contentTarget.removeAttribute("closing")
      this.backdropTarget.removeAttribute("closing")
      this.modalTarget.close()
    })

    document.body.classList.remove('overflow-hidden')

    // Hide after animation completes (150ms)
    // setTimeout(() => {
    //   this.contentTarget.removeAttribute("closing")
    //   this.backdropTarget.removeAttribute("closing")
    //   this.modalTarget.close()
    // }, 600)
  }
}
