import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="indexpageviewer"
export default class extends Controller {

  connect() {

    // Hides any "notice" banner after 4 seconds. Keeps "alert" banners as they are important for user to read
    const alert = document.querySelector(".alert-info")
    if (alert) {
      const awaitTimeout = delay =>
      new Promise(resolve => setTimeout(resolve, delay));

      awaitTimeout(4000).then(() => {
        alert.classList.remove("show")
        console.log("Removed notice")
      });
    }
  }
}
