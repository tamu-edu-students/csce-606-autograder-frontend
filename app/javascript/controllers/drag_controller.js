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
    // Log the event to confirm drag-and-drop is working
    console.log("Dragged item to new position", event)
  }
}