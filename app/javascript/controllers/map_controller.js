import { Controller } from "@hotwired/stimulus";
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder";
import Rails from "rails-ujs";

// Connects to data-controller="map"
export default class extends Controller {

  static values = {
    markersHash: Object,
    routeId: Number,
    routeMode: String,
    googleApiKey: String
  };

  connect() {

    const countApiCalls = function(apiName) {
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

    const update_route_url = function(routeId) {
      const form = new FormData();
      Rails.ajax({
        url: `/routes/${routeId}/update_google_url`,
        type: "PATCH",
        data: form,
        success: function () {
          console.log("Successfully updated google url")
        },
        error: function () {
          console.log("Could not update google url")
        }
      })
    }

    const sendPatch = function(routeId, TimeInSeconds, DistanceInMetres, route_too_short = false) {

      // Convert time and distance data
      let DistanceInKm = 0
      let TimeInMinutes = 0

      if (route_too_short) {
        console.log("Route is too short or non-existent. Overwriting time, distance with 0")
      }
      else {
        DistanceInKm = parseFloat((DistanceInMetres / 1000).toFixed(2))
        TimeInMinutes = Math.round((TimeInSeconds / 60))
        console.log(`Time in min: ${TimeInMinutes}`)
        console.log(`Distance in km: ${DistanceInKm}`)
      }

      // Update route time & distance in db only on edit page
      if (window.location.href.includes("edit")) {

        const form = new FormData();

        form.append('route[distance]', DistanceInKm)
        form.append('route[time]', TimeInMinutes)

        Rails.ajax({
          url: `/routes/${routeId}/move`,
          type: "PATCH",
          data: form,
          success: function () {
            console.log("Successfully updated db for time and distance")
            document.querySelector('#nikspecs').route.add(TimeInMinutes, DistanceInKm)
          },
          error: function () {
            console.log("Could not update db for time and distance")
          }
        })
      }
    }

    async function loadEmptyMap(mapDomElement) {
      const { Map } = await google.maps.importLibrary("maps");
      const map = new Map(mapDomElement, {
          zoom: 9,
          center: { lat: 51.509865, lng: -0.118092 },
          disableDefaultUI: true,
          zoomControl: true,
          mapId: "d8743ef38144c17c",
        });
      console.log("Empty map has loaded")
    }

    async function loadMapWithMarkers(mapDomElement, markers) {
      // Define marker properties
      // const labels = "123456789";
      // let labelIndex = 0;
      const icon = document.createElement("div");
      icon.innerHTML = '<span style="font-size:1.5rem;font-weight:bold;color:white;">1</span>';

      // Load empty map
      const { Map } = await google.maps.importLibrary("maps");
      const map = new Map(mapDomElement, {
          zoom: 9,
          center: { lat: markers[1].lat, lng: markers[1].lng },
          disableDefaultUI: true,
          zoomControl: true,
          mapId: "d8743ef38144c17c",
        });
      console.log("Map has loaded")

      // Load pin
      const { PinElement } = await google.maps.importLibrary("marker")
      const pin = new PinElement({
        scale: 1.3,
        glyph: icon,
        glyphColor: "#0F4C75",
        background: "#0F4C75",
        borderColor: "#3282B8",
      });
      console.log("Pin has loaded")

      // Load marker
      const { AdvancedMarkerElement } = await google.maps.importLibrary("marker");
      const marker = new AdvancedMarkerElement({
        map,
        position: { lat: markers[1].lat, lng: markers[1].lng },
        content: pin.element,
        title: "Some title"
      });
      console.log("Marker has loaded")
    }

    async function main(markers, mapElement, routeId) {

      // Define function variables and load custom maps properties

      // 1. If there is no destination, add empty map
      if (Object.keys(markers).length == 0) {

        // Load empty map
        await loadEmptyMap(mapElement);

        // Update count of api calls
        countApiCalls("maploads");

        // Update time, distance & google url
        sendPatch(routeId, "_", "_", true);
        update_route_url(routeId); // After patch, because patch updates db and update url works with new db entry
      }

      // 2.1 If there is one destination, zoom onto that destination
      else if (Object.keys(markers).length == 1) {

        // Load custom map
        await loadMapWithMarkers(mapElement, markers)

        // Update count of api calls
        countApiCalls("maploads");

        // Update time, distance & google url
        sendPatch(routeId, "_", "_", true);
        update_route_url(routeId); // After patch, because patch updates db and update url works with new db entry
      }

      // 2.2 If there are at least two destinations, fit coordinate bounds
      else if (Object.keys(markers).length >= 2) {

        // Update count of api calls
        // this.#countApiCalls("maploads")

        const map = new google.maps.Map(this.element, {
          zoom: 13,
          disableDefaultUI: true,
          zoomControl: true,
          mapTypeId: 'roadmap'
        });
        console.log("Loaded map")

        const directionsService = new google.maps.DirectionsService();
        const directionsRenderer = new google.maps.DirectionsRenderer({ map: map, suppressBicyclingLayer: true });

        let totalDistanceMeters = 0
        let totalTimeSeconds = 0

        let selectedMode = google.maps.TravelMode.WALKING
        if (this.routeModeValue === "driving") {
          selectedMode = google.maps.TravelMode.DRIVING
        }
        else if (this.routeModeValue === "cycling") {
          selectedMode = google.maps.TravelMode.BICYCLING
        }

        // Extract waypoints
        const waypoints = []
        for (let i = 2; i < Object.keys(markers).length; i++) {
          waypoints.push({
            location: { placeId: markers[i].place_id },
            stopover: true,
          })
        }

        // this.#countApiCalls("directions")

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
          travelMode: selectedMode,
          // avoidFerries: true,
          // avoidTolls: true,
          // avoidHighways: true,
          unitSystem: google.maps.UnitSystem.METRIC
        })
        .then((response) => {

          // If route fetch was successful, add route to map
          directionsRenderer.setDirections(response);

          // Remove all markers

          // label: labels[labelIndex++ % labels.length],

          // Compute total distance and time
          const routeLegs = response.routes[0].legs
          routeLegs.forEach( leg => {
            totalDistanceMeters += leg.distance.value
            totalTimeSeconds += leg.duration.value
          })

          // Update time, distance & google url
          // sendPatch(totalTimeSeconds, totalDistanceMeters)
          // update_route_url() // After patch, because patch updates db and update url works with new db entry

        })
        .catch((e) =>
          // If route fetch was NOT successfull, override time, distance with 0, google url with "N/A"
          sendPatch(routeId, "_", "_", false),
          update_route_url(routeId) // After patch, because patch updates db and update url works with new db entry
        );

      }

      // 2.3 If there is no destination, place default value as route specs
      else {
        sendPatch(routeId, "_", "_", true)
        update_route_url(routeId) // After patch, because patch updates db and update url works with new db entry
      }
    }

    const routeId = this.routeIdValue
    const mapElement = this.element
    const markers = this.markersHashValue
    main(markers, mapElement, routeId)

  }



  // function countApiCalls(apiName) {
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

  // async #initMapAndMarkers() {

    // Load empty map
    // this.map = new Map(mapDomElement, {
    //   zoom: 9,
    //   center: { lat: 51.509865, lng: -0.118092 },
    //   disableDefaultUI: true,
    //   zoomControl: true,
    //   mapId: "d8743ef38144c17c",
    // });


    // console.log("Map is")
    // console.log(this.map)
  // }
  // position: { lat: 51.509865, lng: -0.118092 },


}
