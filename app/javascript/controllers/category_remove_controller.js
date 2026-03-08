import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { categoryId: String }

  confirm(event) {
    const tbody = document.getElementById(`items-for-category-${this.categoryIdValue}`)
    const itemsCount = tbody ? tbody.querySelectorAll("tr").length - 1 : 0
    let message = "Are you sure you want to delete this category?"

    if (itemsCount > 0) {
      message += `\nAll ${itemsCount} item(s) will be deleted with it.`
    }

    if (!confirm(message)) {
      event.preventDefault()
      event.stopImmediatePropagation()
    }
  }
}
