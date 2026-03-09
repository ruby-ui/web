import { Controller } from "@hotwired/stimulus"
import { codeToHtml } from "shiki"

export default class extends Controller {
  static targets = ["code", "output"]
  static values = {
    language: { type: String, default: "ruby" }
  }

  async connect() {
    await this.highlightCode()
  }

  async highlightCode() {
    if (!this.hasCodeTarget || !this.hasOutputTarget) return

    const code = this.codeTarget.textContent
    const lang = this.languageValue
    
    const isDark = document.documentElement.classList.contains('dark')
    const theme = isDark ? 'github-dark' : 'github-light'

    try {
      const html = await codeToHtml(code, {
        lang: lang,
        theme: theme,
        transformers: [
          {
            pre(node) {
              node.properties["class"] = "no-scrollbar min-w-0 overflow-x-auto px-4 py-3.5 outline-none has-[[data-highlighted-line]]:px-0 has-[[data-line-numbers]]:px-0 has-[[data-slot=tabs]]:p-0 !bg-transparent"
              node.properties["data-line-numbers"] = ""
            },
            code(node) {
              node.properties["data-line-numbers"] = ""
            },
            line(node, line) {
              node.properties["data-line"] = line
              this.addClassToHast(node, "line")
            }
          }
        ]
      })

      this.outputTarget.innerHTML = html
    } catch (error) {
      console.error('Shiki highlighting error:', error)
      this.outputTarget.textContent = code
    }
  }
}

