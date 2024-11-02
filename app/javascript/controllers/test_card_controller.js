import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  connect() {
    // Initialize Sortable on this element
    this.sortable = Sortable.create(this.element, {
      animation: 150, // Smooth animation when items are dragged
      onEnd: this.end.bind(this) // Bind the end function to handle drag-end events
    })
  }

  end(event) {
    console.log("Dragged item to new position", event);
  
    // Retrieve correct test IDs from data-id attribute
    const testIds = this.sortable.toArray().map(itemId => {
      return document.querySelector(`[data-id="${itemId}"]`).getAttribute("data-id");
    });
  
    const groupingId = this.element.getAttribute("data-grouping-id");
  
    // Send the reordered IDs to the server
    fetch(`/assignments/${groupingId}/update_test_order`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute("content")
      },
      body: JSON.stringify({ test_ids: testIds })
    })
    .then(response => response.json())
    .then(data => {
      console.log("Order saved successfully:", data);
    })
    .catch(error => {
      console.error("Error saving order:", error);
    });
  }
  

}

