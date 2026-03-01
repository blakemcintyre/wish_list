import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["show", "edit", "nameInput", "quantityInput"]
  static values = { url: String, paramKey: String }

  edit() {
    this.showTargets.forEach(el => el.hidden = true)
    this.editTargets.forEach(el => el.hidden = false)
    this.nameInputTarget.focus()
  }

  cancel() {
    this.editTargets.forEach(el => el.hidden = true)
    this.showTargets.forEach(el => el.hidden = false)
  }

  saveOnEnter(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      this.save()
    }
  }

  async save() {
    const params = { name: this.nameInputTarget.value }
    if (this.hasQuantityInputTarget) {
      params.quantity = this.quantityInputTarget.value
    }

    const response = await fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "text/vnd.turbo-stream.html, text/html, application/xhtml+xml",
        "X-CSRF-Token": this.csrfToken
      },
      body: JSON.stringify({ [this.paramKeyValue]: params })
    })

    if (response.ok) {
      const html = await response.text()
      Turbo.renderStreamMessage(html)
    }
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]').content
  }
}
