import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  connect() {
    // Initialize Sortable on this element
    // this.sortable = Sortable.create(this.element, {
    //   animation: 150, // Smooth animation when items are dragged
    //   onEnd: this.end.bind(this) // Bind the end function to handle drag-end events
    // })
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
    let title = event.currentTarget;
    let testGroupingId = title.getAttribute("data-test-grouping-id");
    let testContainer = this.element.querySelector(`#test-grouping-${testGroupingId}`)

    if (testContainer.style.display === "none" || testContainer.style.display === "") {
      testContainer.style.display = "block";
    }
    else {
      testContainer.style.display = "none";
    }
  }

  // end(event) {
  //   // Log the event to confirm drag-and-drop is working
  //   console.log("Dragged item to new position", event)
  // }
}

