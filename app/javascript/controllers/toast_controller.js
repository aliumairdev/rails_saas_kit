import { Controller } from "@hotwired/stimulus"

// Toast notification controller
// Handles dismissing and auto-dismissing toast notifications
export default class extends Controller {
  static values = {
    dismissable: Boolean,
    dismissAfter: Number
  }

  connect() {
    // Auto-dismiss if configured
    if (this.hasDismissAfterValue && this.dismissAfterValue > 0) {
      this.timeout = setTimeout(() => {
        this.dismiss()
      }, this.dismissAfterValue)
    }
  }

  disconnect() {
    // Clear timeout if component is removed
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    // Add removing class for animation
    this.element.classList.add('toast-removing')

    // Remove element after animation completes
    setTimeout(() => {
      this.element.remove()
    }, 300) // Match animation duration in CSS
  }
}
