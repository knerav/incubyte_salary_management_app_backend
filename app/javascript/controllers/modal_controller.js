import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.showModal()
  }

  close() {
    this.element.close()
    this.element.closest("turbo-frame").innerHTML = ""
  }

  backdropClose(event) {
    if (event.target === this.element) {
      this.close()
    }
  }
}
