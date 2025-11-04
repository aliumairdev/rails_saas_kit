import { Controller } from "@hotwired/stimulus"

// Theme switcher controller
// Handles switching between light and dark themes
// Persists theme preference to localStorage
//
// Usage:
//   <div data-controller="theme">
//     <button data-action="click->theme#toggle">Toggle Theme</button>
//   </div>
export default class extends Controller {
  static values = {
    default: { type: String, default: "light" }
  }

  connect() {
    // Initialize theme from localStorage or use default
    const savedTheme = localStorage.getItem("theme") || this.defaultValue
    this.setTheme(savedTheme)
  }

  toggle() {
    const currentTheme = this.getCurrentTheme()
    const newTheme = currentTheme === "light" ? "dark" : "light"
    this.setTheme(newTheme)
  }

  setTheme(theme) {
    const html = document.documentElement

    // Remove all theme classes
    html.classList.remove("light", "dark")

    // Add new theme class
    html.classList.add(theme)

    // Save to localStorage
    localStorage.setItem("theme", theme)

    // Dispatch custom event for other components that might need to react
    window.dispatchEvent(new CustomEvent("theme-changed", {
      detail: { theme }
    }))
  }

  getCurrentTheme() {
    return document.documentElement.classList.contains("dark") ? "dark" : "light"
  }

  // Allow external components to set theme directly
  setLight() {
    this.setTheme("light")
  }

  setDark() {
    this.setTheme("dark")
  }

  // Check if user prefers dark mode from system settings
  prefersDarkMode() {
    return window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches
  }

  // Use system preference
  useSystemPreference() {
    const theme = this.prefersDarkMode() ? "dark" : "light"
    this.setTheme(theme)
  }
}
