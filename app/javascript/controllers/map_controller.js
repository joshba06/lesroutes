import { Controller } from "@hotwired/stimulus";
import MapboxGeocoder from "@mapbox/mapbox-gl-geocoder";
import Rails from "rails-ujs";

// Connects to data-controller="map"
export default class extends Controller {

  static values = {
    apiKey: String,
    markers: Array,
    routeId: Number,
    routeMode: String,
  };

  connect() {
    // console.log("Hello from MAP controller");
    mapboxgl.accessToken = this.apiKeyValue;

    // 0. Convert markers
    const markersarray = this.markersValue;
    const sortedmarkers = {}
    markersarray.forEach((marker) => {
      sortedmarkers[marker.pos] = {lat: marker.lat, lng: marker.lng, marker_html: marker.marker_html}
    })

    // 1. Load empty map
    let map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v10",
      center: [-0.118092, 51.509865],
      zoom: 6,
      });
    // console.log("Created empty map")

    // Update count of api calls
    this.#countApiCalls("maploads")


    // 2.1 If there is one destination, zoom onto that destination
    if (Object.keys(sortedmarkers).length == 1) {
      console.log("There is one destination")

      map.setCenter([sortedmarkers[1].lng, sortedmarkers[1].lat]);
      map.setZoom(13);

      this.#addMarkersToMap(sortedmarkers, map);

      this.#sendPatch("_", true);
    }

    // 2.2 If there are at least two destinations, fit coordinate bounds
    else if (Object.keys(sortedmarkers).length >= 2) {
      console.log("There are at least 2 destinations")

      this.#addMarkersToMap(sortedmarkers, map);
      this.#fitMapToMarkers(sortedmarkers, map);

      // 2.3.1 Get route data from mapbox

      // Create  query string
      console.log(`Route mode: ${this.routeModeValue}`)

      let fetchQueryString =
      `https://api.mapbox.com/directions/v5/mapbox/${this.routeModeValue === "driving" ? "driving-traffic" : this.routeModeValue}/`;

      let i = 1;
      for (const key in sortedmarkers) {

        if (i == Object.keys(sortedmarkers).length) {
          fetchQueryString =
            fetchQueryString +
            sortedmarkers[key].lng +
            "," +
            sortedmarkers[key].lat +
            `?${this.routeModeValue === "driving" ? "exclude=ferry%2Ctoll" : "exclude=ferry"}&geometries=geojson&access_token=${mapboxgl.accessToken}`;
        } else {
          fetchQueryString =
            fetchQueryString + sortedmarkers[key].lng + "," + sortedmarkers[key].lat + ";";
        }
        i += 1;
      };
      console.log(`Query string: ${fetchQueryString}`)

      this.#fetchRoute(fetchQueryString, map);
    }

    // 2.3 If there is no destination, place default value as route specs
    else {
      console.log("No destination found")
      this.#sendPatch("_", true);
    }
  }

  #addMarkersToMap(sortedmarkers, map) {
    for (const key in sortedmarkers) {

      const customMarker = document.createElement("div")
      customMarker.innerHTML = sortedmarkers[key].marker_html

      new mapboxgl.Marker(customMarker)
        .setLngLat([sortedmarkers[key].lng, sortedmarkers[key].lat])
        .addTo(map);
    };
    console.log("Added markers to map")
  }

  #fitMapToMarkers(sortedmarkers, map) {
    const bounds = new mapboxgl.LngLatBounds();

    // Extend the 'LngLatBounds' to include every coordinate in the bounds result.
    for (const key in sortedmarkers) {
      bounds.extend([sortedmarkers[key].lng, sortedmarkers[key].lat]);
    }

    map.fitBounds(bounds, {
      padding: 80,
      duration: 0,
    });
    console.log("Fitted map bounds to markers")
  }

  #fetchRoute(fetchQueryString, map) {
    fetch(fetchQueryString)
      .then((response) => response.json())
      .then((data) => {

        // Update count of api calls
        this.#countApiCalls("directions")

        // Overwrite google_url with "no_route_found" if mapbox cannot determine route
        if (data.code === "NoRoute") {

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
            this.#sendPatch(data, true)
          }
          else {
            // On Show page, don't do anything
            console.log("Show page. No database update needed")
          }
        }
        else {
          const route = data.routes[0].geometry.coordinates;
          const geojson = {
            type: "Feature",
            properties: {},
            geometry: {
              type: "LineString",
              coordinates: route,
            },
          };

          map.on('load', function() {
            console.log("Map has loaded")

            map.addSource("route-details", {
              type: 'geojson',
              data: geojson,
            });
            console.log("1 Added route data to map")

            map.addLayer({
              id: 'route',
              type: 'line',
              source: 'route-details',
              layout: {
                "line-join": "round",
                "line-cap": "round",
              },
              paint: {
                "line-color": "#3887be",
                "line-width": 5,
                "line-opacity": 0.75,
              },
            });
            console.log("2 Added route layer to map")
          })

          this.#sendPatch(data)
        }

      });
  }

  #sendPatch(data, route_too_short = false) {

    // Only update db and route specs on edit page, not on show page
    if (window.location.href.includes("edit")) {
      console.log("We are on the edit page")

      const routeId = this.routeIdValue
      const form = new FormData();

      let TimeInMinutes = 0
      let DistanceInKm = 0

      if (route_too_short) {
        console.log("Route is too short or non-existent. Overwriting time, distance with 0")
      }
      else {
        const DistanceInMetres = data.routes[0].distance
        const TimeInSeconds = data.routes[0].duration
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
    else {
      console.log("We are on the show page")
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
