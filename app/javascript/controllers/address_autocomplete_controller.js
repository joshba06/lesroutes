import { Controller } from "@hotwired/stimulus";
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder";
import Rails from "rails-ujs";

// Connects to data-controller="address-autocomplete"
export default class extends Controller {
  static values = {
    apiKey: String,
  }
  static targets = ["title", "address", "city", "latitude", "longitude", "unspecificPlacename"]


  connect() {
    this.geocoder = new MapboxGeocoder({
      accessToken: this.apiKeyValue,
      types: "neighborhood,address,poi"
    })

    // Event listener on search field to scroll itinerary into view
    window.addEventListener("load", (event) => {
      document.querySelector(".mapboxgl-ctrl-geocoder").addEventListener("click", this.#scroll_into_view);
    });

    this.geocoder.addTo(this.element)
    this.geocoder.on("result", event => this.#setInputValue(event))
    this.geocoder.on("clear", () => this.#clearInputValue())
  }

  #setInputValue(event) {
    // console.log(event.result)

    this.#checkForUnclearTitles(event.result["text"])

    this.addressTarget.value = event.result["place_name"]

    // Update API "count" twice for initial geocoding and place title check
    this.#countApiCalls("geocoding")
    this.#countApiCalls("geocoding")

    // Get coordinates, address, poi & city from event.result. Store them in params and send to create method
    // Coordinates
    this.latitudeTarget.value = event.result["geometry"]["coordinates"][1]
    this.longitudeTarget.value = event.result["geometry"]["coordinates"][0]

    // City
    let city = null
    let district = null
    event.result["context"].forEach((hash) => {
      for (const [key, value] of Object.entries(hash)) {
        if (value.includes("place")) {
          city = hash["text"]
        }
        else if (value.includes("district")) {
          district = hash["text"]
        }
      }
    })
    this.cityTarget.value = city === null ? district : city

    // 1. If POI
    if (event.result["id"].includes("poi")) {

      // Title
      this.titleTarget.value = event.result["text"]
    }
    else {

      // Title
      this.titleTarget.value = "Custom location"
    }
  }

  #clearInputValue() {
    this.addressTarget.value = ""
  }

  disconnect() {
    this.geocoder.onRemove()
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

  #checkForUnclearTitles(place_name){

    this.unspecificPlacenameTarget.checked = false

    const fetchQueryString = `https://api.mapbox.com/geocoding/v5/mapbox.places/${place_name}.json?&access_token=${this.apiKeyValue}`;
    fetch(fetchQueryString)
    .then((response) => response.json())
    .then((data) => {
      // console.log(data)

      const places_hash = {}
      data.features.forEach((result) => {
        // Add place title as key and append city to value array
        let title = result["text"]
        let city = ""
        result.context.forEach((place_hash) => {
          if (place_hash["id"].includes("place")) {
            city = place_hash["text"]
          }
        })
        // console.log(`Place: ${title}, city: ${city}`)

        // If key doesnt exist, create one with array as value, otherwise, append to array
        if (title in places_hash) {
          places_hash[title].push(city)
        }
        else {
          places_hash[title] = [city]
        }
      })

      // Check if same exact place name exists in multiple cities
      for (const key in places_hash) {
        const cities = places_hash[key]
        const unique_cities = [... new Set(cities)]
        if (cities.length !== unique_cities.length) {
          // console.log(`${key} exists multiple times in the same city`)
          this.unspecificPlacenameTarget.checked = true
        }
      }
      // console.log(places_hash)
    })
  }

  #scroll_into_view() {
    const itinerary = document.getElementById("scroll-into-view-container");
    itinerary.style.height = "100vh";
    itinerary.scrollIntoView();
  }
}
