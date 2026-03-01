import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nameInput", "quantityInput"]
  static values = { url: String, categoryId: String, listId: String }

  async submit(event) {
    if (event.key !== "Enter") return
    event.preventDefault()

    const name = this.nameInputTarget.value.trim()
    if (name === "") return

    const response = await fetch(this.urlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "text/vnd.turbo-stream.html, text/html, application/xhtml+xml",
        "X-CSRF-Token": this.csrfToken
      },
      body: JSON.stringify({
        item: {
          name: name,
          category_id: this.categoryIdValue,
          quantity: this.quantityInputTarget.value,
          list_id: this.listIdValue
        }
      })
    })

    if (response.ok) {
      const html = await response.text()
      Turbo.renderStreamMessage(html)
      this.nameInputTarget.value = ""
      this.quantityInputTarget.value = 1
      this.nameInputTarget.focus()
    }
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]').content
  }
}
