import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gif-loop"
export default class extends Controller {
  static targets = ["gif"]

  connect() {
    console.log(this.gifTarget.src)
    setInterval(() => {
      this.gifTarget.src = "https://res.cloudinary.com/dcuj8efm3/image/upload/v1678444548/map_animated_d4rahd.gif"
    }, 6000);
  }
}
