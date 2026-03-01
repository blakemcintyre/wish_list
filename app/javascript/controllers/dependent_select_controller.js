import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["target"]
  static values = { url: String, excludeId: Number, includeBlank: Boolean }

  async change(event) {
    const listId = event.target.value
    const url = this.urlValue.replace(":list_id", listId)

    const response = await fetch(url, {
      headers: { "Accept": "application/json" }
    })
    const categories = await response.json()

    const select = this.targetTarget
    select.innerHTML = ""

    if (this.includeBlankValue) {
      select.add(document.createElement("option"))
    }

    categories.forEach(category => {
      if (this.hasExcludeIdValue && category.id === this.excludeIdValue) return

      const option = document.createElement("option")
      option.text = category.name
      option.value = category.id
      select.add(option)
    })
  }
}
