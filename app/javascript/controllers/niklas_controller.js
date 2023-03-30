import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="new-route"
export default class extends Controller {
  static targets = ["time", "distance"]
  static values = {
    time: Number,
    distance: Number,
  };

  connect() {
    console.log("Ciao from niklas controller")
    this.element[this.identifier] = this

  }

  add(TimeInMinutes, DistanceInKm) {
    console.log("Routed to niklas controller")
    console.log(`New time: ${TimeInMinutes}`)

    this.distanceTarget.innerText = DistanceInKm
    this.timeTarget.innerText = TimeInMinutes
    console.log("Updated display of time and distance :) ")
  }
}
