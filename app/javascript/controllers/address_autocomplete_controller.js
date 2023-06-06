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
    console.log(place.place_id)
    console.log(this.placeIdTarget.value)
    // // Update API "count" twice for initial geocoding and place title check
    // // this.#countApiCalls("geocoding")
    // // this.#countApiCalls("geocoding")

    this.latitudeTarget.value = place.geometry.location.lat()
    this.longitudeTarget.value = place.geometry.location.lng()
    this.titleTarget.value = place.name
    this.placeIdTarget.value = place.place_id
    this.addressTarget.value = place.formatted_address
    }

  #clearInputValue() {
    this.addressTarget.value = ""
  }
}

  // #countApiCalls(apiName) {
  //   // apiName: "directions", "geocoding", or "maploads"

  //   const form = new FormData();
  //   form.append(`api_call[${apiName}]`, "update")

  //   Rails.ajax({
  //     url: `/apicalls/${apiName}`,
  //     type: "PATCH",
  //     data: form,
  //     success: function () {
  //       console.log(`Successfully updated api count for: ${apiName}`)
  //     },
  //     error: function () {
  //       console.log(`Could not update api count for: ${apiName}`)
  //     }
  //   })
  // }

  // #checkForUnclearTitles(place_name){

  //   this.unspecificPlacenameTarget.checked = false

  //   const fetchQueryString = `https://api.mapbox.com/geocoding/v5/mapbox.places/${place_name}.json?&access_token=${this.apiKeyValue}`;
  //   fetch(fetchQueryString)
  //   .then((response) => response.json())
  //   .then((data) => {
  //     // console.log(data)

  //     const places_hash = {}
  //     data.features.forEach((result) => {
  //       // Add place title as key and append city to value array
  //       let title = result["text"]
  //       let city = ""
  //       result.context.forEach((place_hash) => {
  //         if (place_hash["id"].includes("place")) {
  //           city = place_hash["text"]
  //         }
  //       })
  //       // console.log(`Place: ${title}, city: ${city}`)

  //       // If key doesnt exist, create one with array as value, otherwise, append to array
  //       if (title in places_hash) {
  //         places_hash[title].push(city)
  //       }
  //       else {
  //         places_hash[title] = [city]
  //       }
  //     })

  //     // Check if same exact place name exists in multiple cities
  //     for (const key in places_hash) {
  //       const cities = places_hash[key]
  //       const unique_cities = [... new Set(cities)]
  //       if (cities.length !== unique_cities.length) {
  //         // console.log(`${key} exists multiple times in the same city`)
  //         this.unspecificPlacenameTarget.checked = true
  //       }
  //     }
  //     // console.log(places_hash)
  //   })
  // }

  // #scroll_into_view() {
  //   const itinerary = document.getElementById("scroll-into-view-container");
  //   itinerary.style.height = "100vh";
  //   itinerary.scrollIntoView();
  // }
// }
