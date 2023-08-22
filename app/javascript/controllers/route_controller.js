import { Controller } from "@hotwired/stimulus"
import Rails from "rails-ujs";

// Connects to data-controller="route"
export default class extends Controller {
  static targets = ["time", "distance", "routeTitle", "formUpdateRouteCity", "specElement", "formUpdateRouteTitle", "filterButton", "filterMenu", "dropdownElement"]
  static values = {
    time: Number,
    distance: Number,
  };

  connect() {
    this.element[this.identifier] = this
  }

  add(TimeInMinutes, DistanceInKm) {

    // Format time for display
    if (TimeInMinutes < 60){
      this.timeTarget.innerText = `${TimeInMinutes} min`
    }
    else {
      const m = TimeInMinutes % 60
      const h = (TimeInMinutes-m)/60
      this.timeTarget.innerText = `${h}:${m} h`
    }

    // Format distance for display
    if (DistanceInKm < 100){
      this.distanceTarget.innerText = `${DistanceInKm} km`
    }
    else {
      this.distanceTarget.innerText = `${Math.ceil(DistanceInKm)} km`
    }
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


  toggle_filter_menu (event) {
    event.stopPropagation();
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

  share_route(event) {

    const message = "Are you sure you want to make this route public? Everyone on the web will be able to see it!"

    if (confirm(message)) {
      const form = new FormData();
      form.append('route[shared]', true)

      Rails.ajax({
        url: `/routes/${event.currentTarget.dataset.routeId}/share_route`,
        type: "PATCH",
        data: form,
        success: function () {
          console.log("Successfully shared route")
          location.reload();
        },
        error: function () {
          console.log("Could not share route")
        }
      })
    }
    else {
      console.log("User cancelled route sharing")
    }
  }

  stop_sharing_route(event) {

    const form = new FormData();
    form.append('route[shared]', false)

    Rails.ajax({
      url: `/routes/${event.currentTarget.dataset.routeId}/stop_sharing_route`,
      type: "PATCH",
      data: form,
      success: function () {
        console.log("Stopped sharing route")
        location.reload();
      },
      error: function () {
        console.log("Could not stop sharing route")
      }
    })


  }

}
