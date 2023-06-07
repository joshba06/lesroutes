import { Controller } from "@hotwired/stimulus";
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder";
import Rails from "rails-ujs";

// Connects to data-controller="map"
export default class extends Controller {

  static values = {
    apiKey: String,
    markersHash: Object,
    routeId: Number,
    routeMode: String,
  };

  connect() {
    mapboxgl.accessToken = this.apiKeyValue;
    const markers = this.markersHashValue

    // 1. If there is no destination, add empty map
    if (Object.keys(markers).length == 0) {
      // Update count of api calls
      this.#countApiCalls("maploads")
      const map = new google.maps.Map(this.element, {
        zoom: 7,
        center: { lat: 51.509865, lng: -0.118092 },
        disableDefaultUI: true,
        zoomControl: true,
        mapTypeId: 'roadmap'
      });
      this.#noRouteFound()
    }

    // 2.1 If there is one destination, zoom onto that destination
    else if (Object.keys(markers).length == 1) {

      // Update count of api calls
      this.#countApiCalls("maploads")
      const map = new google.maps.Map(this.element, {
        zoom: 13,
        center: { lat: markers[1].lat, lng: markers[1].lng },
        disableDefaultUI: true,
        zoomControl: true,
        mapTypeId: 'roadmap'
      });

      new google.maps.Marker({
        position: new google.maps.LatLng(markers[1].lat, markers[1].lng),
        map,
        // icon: "https://res.cloudinary.com/ditrbablt/image/upload/v1686139357/marker_1_tcfzug.png",
      });

      this.#noRouteFound()
    }

    // 2.2 If there are at least two destinations, fit coordinate bounds
    else if (Object.keys(markers).length >= 2) {

      // Update count of api calls
      this.#countApiCalls("maploads")

      const map = new google.maps.Map(this.element, {
        zoom: 13,
        disableDefaultUI: true,
        zoomControl: true,
        mapTypeId: 'roadmap'
      });

      const directionsService = new google.maps.DirectionsService();
      const directionsRenderer = new google.maps.DirectionsRenderer({ map: map });

      let totalDistanceMeters = 0
      let totalTimeSeconds = 0

      // Extract waypoints
      const waypoints = []
      for (let i = 2; i < Object.keys(markers).length; i++) {
        waypoints.push({
          location: { placeId: markers[i].place_id },
          stopover: true,
        })
      }

      this.#countApiCalls("directions")
      directionsService
      .route({
        origin: {
          placeId: markers[1].place_id
        },
        destination: {
          placeId: markers[Object.keys(markers).length].place_id,
        },
        waypoints: waypoints,
        optimizeWaypoints: false,
        travelMode: google.maps.TravelMode.DRIVING,
        avoidFerries: true,
        avoidTolls: true,
        unitSystem: google.maps.UnitSystem.METRIC
      })
      .then((response) => {
        directionsRenderer.setDirections(response);

        // Compute total distance and time
        const routeLegs = response.routes[0].legs
        console.log(routeLegs)
        routeLegs.forEach( leg => {
          totalDistanceMeters += leg.distance.value
          totalTimeSeconds += leg.duration.value
        })

        // Update time and distance
        this.#sendPatch(totalTimeSeconds, totalDistanceMeters)

      })
      .catch((e) =>
        this.#noRouteFound()
      );

    }

    // 2.3 If there is no destination, place default value as route specs
    else {
      // console.log("No destination found")
      this.#sendPatch(_, _, true)
    }
  }

  #noRouteFound() {
    console.log("No route found")

    if (window.location.href.includes("edit")) {
      // On Edit page, replace route.google_url with "no_route_found". Update route.time and distance
      const form = new FormData();
      form.append('route[google_url]', "no_route_found")

      Rails.ajax({
        url: `/routes/${this.routeIdValue}/noroute`,
        type: "PATCH",
        data: form,
        success: function () {
          console.log("Successfully updated route information for error")
        },
        error: function () {
          console.log("Could not update route info for error")
        }
      })

      // Update database and display with time and distance
      this.#sendPatch(_, _, true)
    }

  }

  #sendPatch(TimeInSeconds, DistanceInMetres, route_too_short = false) {

    // Only update db and route specs on edit page, not on show page
    if (window.location.href.includes("edit")) {

      const routeId = this.routeIdValue
      const form = new FormData();

      let DistanceInKm = 0
      let TimeInMinutes = 0

      if (route_too_short) {
        console.log("Route is too short or non-existent. Overwriting time, distance with 0")
      }
      else {
        DistanceInKm = parseFloat((DistanceInMetres / 1000).toFixed(2))
        TimeInMinutes = Math.round((TimeInSeconds / 60))
      }

      console.log(`Time in min: ${TimeInMinutes}`)
      console.log(`Distance in km: ${DistanceInKm}`)

      form.append('route[distance]', DistanceInKm)
      form.append('route[time]', TimeInMinutes)

      Rails.ajax({
        url: `/routes/${routeId}/move`,
        type: "PATCH",
        data: form,
        success: function () {
          console.log("Successfully updated route information")
          document.querySelector('#nikspecs').route.add(TimeInMinutes, DistanceInKm)
        },
        error: function () {
          console.log("Could not update route info")
        }
      })
    }
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
}
