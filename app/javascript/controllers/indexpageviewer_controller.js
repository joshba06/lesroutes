import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="indexpageviewer"
export default class extends Controller {
  static targets = ["newRouteButton", "introText"]

  connect() {
    console.log("Hellow from index page viewer controller")
    // On private index page, add new route button to view
    const awaitTimeout = delay =>
    new Promise(resolve => setTimeout(resolve, delay));

    awaitTimeout(3500).then(() => {
      this.introTextTargets.forEach((element) => {
        element.classList.add("hidden")
      })
      this.newRouteButtonTarget.classList.remove("hidden")
    });
  }
}
