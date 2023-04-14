import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="route"
export default class extends Controller {
  static targets = ["time", "distance", "routeTitle", "formUpdateRouteCity", "specElement", "formUpdateRouteTitle", "filterMenu", "dropdownElement"]
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

  edit_city (event) {
    this.specElementTargets.forEach((div) => {
      div.style.display = "none";
    })
    this.formUpdateRouteCityTarget.classList.remove("hidden")
  }



  toggle_filter_menu () {
    console.log("I am here")
    if (this.filterMenuTarget.classList.contains("hidden")) {
      this.filterMenuTarget.classList.remove("hidden")
    }
    else {
      this.filterMenuTarget.classList.add("hidden")
    }

  }

  toggle_dropdown (event) {
    event.stopPropagation();
    event.preventDefault();
  }

}
