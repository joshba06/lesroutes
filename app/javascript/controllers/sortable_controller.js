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

    // console.log(this.element.dataset.count);
    // console.log(this.element.dataset.routeDestinationsCount);
  }

  end(event) {
    console.log(event);

    // * Route Destination ID
    let id = event.item.dataset.id;
    // console.log(id);

    // console.log(this.element.dataset.count);

    let data = new FormData();
    // console.log("Data")
    // console.log(data)

    if (event.newIndex === 0) {
      data.append("position", 1);
    } else {
      data.append("position", event.newIndex + 1);
    }

    for (const [key, value] of data.entries()) {
      console.log(`${key}: ${value}`);
    }

    // * Route ID
    let routeId = this.element.dataset.routeId;
    // console.log("Route ID");
    // console.log(routeId);
    console.log(this.data.get("url").replace(":id", id))

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
