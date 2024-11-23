import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  connect() {
   //Initialize Sortable on this element
    this.sortable = Sortable.create(this.element, {
      animation: 150, // Smooth animation when items are dragged
      onEnd: this.end.bind(this) // Bind the end function to handle drag-end events
    })
    console.log("Reached")
    let testGroupingTitles = this.element.querySelectorAll(".test-grouping-title");
    testGroupingTitles.forEach((title) => {
      title.addEventListener("click", this.toggleTestGrouping.bind(this));
      console.log(`Title: ${title}`)
    })

    // let testGroupings = this.element.queurySelectorAll(".test-grouping-card")
    // let testGroupingList = this.element.queurySelector(".test-grouping-list")

    // let sortedTestGroupings = Array.from(testGroupings).sort((a, b) => {
    //   return parseInt(a.getAttribute(""))
    // })
  }

  toggleTestGrouping(event) {
    console.log("Toggle")
    console.log(`Event: ${JSON.stringify(event)}`)
    let title = event.currentTarget;
    console.log(`Title: ${title}`)
    let testGroupingId = title.getAttribute("data-test-grouping-id");
    console.log(`Test Grouping ID: ${testGroupingId}`)
    let testContainer = this.element.querySelector(`#test-list-${testGroupingId}`)

    console.log(`Test Container: ${testContainer}`)

    if (testContainer) {
      testContainer.classList.toggle("visible");
    }
  }

  end(event) {
    console.log("Dragged test grouping to new position", event);

      // Capture all current test group IDs in the new order
    const testGroupingIds = this.sortable.toArray().map(itemId => {
      return document.querySelector(`[data-id="${itemId}"]`).getAttribute("data-id");
    });
  
    console.log("Reordered Test Grouping IDs:", testGroupingIds);

    const assignmentId = this.element.getAttribute("data-assignment-id");

    // Send the reordered IDs to the server
    fetch(`/assignments/${assignmentId}/update_test_grouping_order`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute("content")
      },
      body: JSON.stringify({ grouping_ids: testGroupingIds })
    })
    .then(response => response.json())
    .then(data => {
      console.log("Order of test groupings saved successfully:", data);
    })
    .catch(error => {
      console.error("Error saving order of test groupings:", error);
    });
  }
}

