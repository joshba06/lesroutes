import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="route"
export default class extends Controller {
  static targets = ["time", "distance", "routeTitle", "formUpdateRouteTitle"]
  static values = {
    time: Number,
    distance: Number,
  };

  connect() {
    console.log("Ciao from route controller")
    this.element[this.identifier] = this
  }

  add(TimeInMinutes, DistanceInKm) {
    console.log("Routed to route controller")
    console.log(`New time: ${TimeInMinutes}`)

    this.distanceTarget.innerText = DistanceInKm
    this.timeTarget.innerText = TimeInMinutes
    console.log("Updated display of time and distance on edit page")
    console.log("Goodbye from route controller")
  }

  edit_title (event) {
    this.routeTitleTarget.style.display = "none";
    this.formUpdateRouteTitleTarget.classList.remove("hidden")


  }


}
