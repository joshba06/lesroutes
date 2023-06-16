// src/controllers/sortable_controller.js

import { Controller } from "@hotwired/stimulus";
import Rails from "rails-ujs";
import Sortable from "sortablejs";

export default class extends Controller {
  // static targets = ["results"];

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      delay: 40,
      delayOnTouchOnly: true,
      ghostClass: "blue-background-class",
      onEnd: this.end.bind(this),
    });
  }

  end(event) {

    // Get index before change
    const oldIndex = event.oldIndex

    // Only reload page, if order of items was changed
    if (oldIndex !== event.newIndex) {

      // * Route Destination ID
      let id = event.item.dataset.id;

      let data = new FormData();

      if (event.newIndex === 0) {
        data.append("position", 1);
      } else {
        data.append("position", event.newIndex + 1);
      }

      // * Route ID
      let routeId = this.element.dataset.routeId;

      // Update route_destination position in "route_destination" table
      Rails.ajax({
        url: this.data.get("url").replace(":id", id),
        type: "PATCH",
        data: data,
        success: function () {
          console.log("Order of route destinations updated");
          document.location.reload();
        },
      });
    }
  }
}
