import { Controller } from "@hotwired/stimulus";
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder";
import Rails from "rails-ujs";

// Connects to data-controller="map"
export default class extends Controller {

  static values = {
    markersHash: Object,
    routeId: Number,
    routeMode: String,
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

    async function update_route_url (routeId) {
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

    async function sendPatch (routeId, TimeInSeconds, DistanceInMetres, route_too_short = false) {

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

    async function loadMapWithMarkers(routeId, mapDomElement, markers, routeMode = null) {

      // Load map library
      const { Map } = await google.maps.importLibrary("maps");
      let map;

      // Load directions, if at least 2 destinations exist
      if (Object.keys(markers).length >= 2) {

        // Load empty map
        map = new Map(mapDomElement, {
          disableDefaultUI: true,
          zoomControl: true,
          mapId: "d8743ef38144c17c",
        });

        // Define direction parameters
        const directionsService = new google.maps.DirectionsService();
        const directionsRenderer = new google.maps.DirectionsRenderer({
                                                                        map: map,
                                                                        suppressBicyclingLayer: true,
                                                                        suppressMarkers: true });
        let totalDistanceMeters = 0
        let totalTimeSeconds = 0

        let selectedMode = google.maps.TravelMode.WALKING
        if (routeMode === "driving") {
          selectedMode = google.maps.TravelMode.DRIVING
        }
        else if (routeMode === "cycling") {
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

        // Fetch directions
        const response = await directionsService
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
          unitSystem: google.maps.UnitSystem.METRIC
        })
        if (response.status === "OK") {

          // Replace coords in markers object with start- and end point of route leg for better visual accuracy
          let j = 1
          response.routes[0].legs.forEach( leg => {
            markers[j].lat = leg.start_location.lat()
            markers[j].lng = leg.start_location.lng()
            if (j === response.routes[0].legs.length) {
              markers[j+1].lat = leg.end_location.lat()
              markers[j+1].lng = leg.end_location.lng()
            }
            j += 1
          })

          // If route fetch was successful, add route to map
          directionsRenderer.setDirections(response);

          // Compute total distance and time
          const routeLegs = response.routes[0].legs
          routeLegs.forEach( leg => {
            totalDistanceMeters += leg.distance.value
            totalTimeSeconds += leg.duration.value
          })

          // Update time, distance & google url
          await sendPatch(routeId, totalTimeSeconds, totalDistanceMeters)
          await update_route_url(routeId) // After patch, because patch updates db and update url works with new db entry
        }
        else {
          console.log("Could not find route")
          await sendPatch(routeId, "_", "_", true)
          await update_route_url(routeId) // After patch, because patch updates db and update url works with new db entry
        }
      }
      // Load map and center on 1 destination, if only 1 exists
      else {
        map = new Map(mapDomElement, {
          zoom: 13,
          center: { lat: parseFloat(markers[1].lat), lng: parseFloat(markers[1].lng) },
          disableDefaultUI: true,
          zoomControl: true,
          mapId: "d8743ef38144c17c",
        });
      }

      // Add marker(s) to the map
      const { AdvancedMarkerElement } = await google.maps.importLibrary("marker");
      const { PinElement } = await google.maps.importLibrary("marker");

      let counter = 0
      for (const key in markers) {

        // Customize pin
        let icon = document.createElement("div")
        icon.innerHTML = `<span style="font-size:1.3rem;font-weight:bold;color:white;">${key}</span>`;

        let pin = new PinElement({
          scale: 1.3,
          glyph: icon,
          glyphColor: "#0F4C75",
          background: "#0F4C75",
          borderColor: "#3282B8",
        });

        let marker = new AdvancedMarkerElement({
          map,
          position: { lat: parseFloat(markers[key].lat), lng: parseFloat(markers[key].lng) },
          content: pin.element,
          // title: "Some title"
        });
        counter += 1
      }
      // console.log(`Added ${counter} markers.`);
    }

    async function main(markers, mapElement, routeId, routeMode) {

      // If there is one destination, zoom onto that destination
      if (Object.keys(markers).length == 1) {

        // Load custom map
        await loadMapWithMarkers(routeId, mapElement, markers)

        // Update count of api calls
        countApiCalls("maploads");

        // Update time, distance & google url
        sendPatch(routeId, "_", "_", true);
        update_route_url(routeId); // After patch, because patch updates db and update url works with new db entry
      }

      // If there are at least two destinations, fit coordinate bounds
      else if (Object.keys(markers).length >= 2) {


        // Load custom map and directions
        await loadMapWithMarkers(routeId, mapElement, markers, routeMode)

        // Update count of api calls
        countApiCalls("maploads");
      }

      // If there is no destination, add empty map
      else {
        // Load empty map
        await loadEmptyMap(mapElement);

        // Update count of api calls
        countApiCalls("maploads");

        // Update time, distance & google url
        sendPatch(routeId, "_", "_", true);
        update_route_url(routeId); // After patch, because patch updates db and update url works with new db entry
      }
    }

    // Define variables needed in functions
    const routeId = this.routeIdValue
    const mapElement = this.element
    const markers = this.markersHashValue

    // Run main script
    main(markers, mapElement, routeId, this.routeModeValue)

  }
}
