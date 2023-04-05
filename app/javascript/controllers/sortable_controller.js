// src/controllers/sortable_controller.js

import { Controller } from "@hotwired/stimulus";
import Rails from "rails-ujs";
import Sortable from "sortablejs";

export default class extends Controller {
  // static targets = ["results"];

  connect() {
    console.log("Sortable controller is connected!");

    this.sortable = Sortable.create(this.element, {
      animation: 150,
      ghostClass: "blue-background-class",
      onEnd: this.end.bind(this),
    });
  }

  end(event) {

    // Get index before change
    const oldIndex = event.oldIndex

    // * Route Destination ID
    let id = event.item.dataset.id;

    let data = new FormData();

    if (event.newIndex === 0) {
      data.append("position", 1);
    } else {
      data.append("position", event.newIndex + 1);
    }

    // for (const [key, value] of data.entries()) {
    //   console.log(`${key}: ${value}`);
    // }

    // * Route ID
    let routeId = this.element.dataset.routeId;

    console.log(`Changing order of route id: ${this.element.dataset.routeId}`)
    console.log(`${oldIndex + 1} -> ${event.newIndex + 1}`)

    console.log(this.data.get("url").replace(":id", id))

    // Update route_destination position in "route_destination" table
    Rails.ajax({
      url: this.data.get("url").replace(":id", id),
      type: "PATCH",
      data: data,
      success: function () {
        console.log("Page is reloading...");
        document.location.reload();

        // fetch(`/routes/${routeId}`)
        //   .then((res) => res.json())
        //   .then((data) => console.log(data));
      },
    });
  }
}
