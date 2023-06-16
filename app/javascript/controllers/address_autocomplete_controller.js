import { Controller } from "@hotwired/stimulus";
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder";
import Rails from "rails-ujs";

// Connects to data-controller="address-autocomplete"
export default class extends Controller {
  static values = {
    apiKey: String,
    routeId: String,
  }
  static targets = ["title", "address", "placeId", "fullAddress", "latitude", "longitude"]


  connect() {
    const input = this.fullAddressTarget
    const options = {
      fields: ["place_id", "formatted_address", "geometry", "name"],
      strictBounds: false,
    };


    const autocomplete = new google.maps.places.Autocomplete(input, options);

    // Display search results when user enters location
    autocomplete.addListener("place_changed", () => {

      const place = autocomplete.getPlace();

      if (!place.geometry || !place.geometry.location) {
        this.addressTarget.value = ""
      }
      else {
        this.#setInput(place)
      }
    })
  }

  #setInput(place) {

    // Update Google API Autocomplete + Place Details - Per session "count"
    this.#countApiCalls("geocoding")

    this.latitudeTarget.value = place.geometry.location.lat()
    this.longitudeTarget.value = place.geometry.location.lng()
    this.titleTarget.value = place.name
    this.placeIdTarget.value = place.place_id
    this.addressTarget.value = place.formatted_address
    }


  #countApiCalls(apiName) {
    // apiName: "directions", "geocoding", or "maploads"

    const form = new FormData();
    form.append(`api_call[${apiName}]`, "update")

    Rails.ajax({
      url: `/apicalls/${apiName}`,
      type: "PATCH",
      data: form,
      success: function () {
        console.log(`Successfully updated api count for: ${apiName}`)
      },
      error: function () {
        console.log(`Could not update api count for: ${apiName}`)
      }
    })
  }

  // #scroll_into_view() {
  //   const itinerary = document.getElementById("scroll-into-view-container");
  //   itinerary.style.height = "100vh";
  //   itinerary.scrollIntoView();
  // }
}
