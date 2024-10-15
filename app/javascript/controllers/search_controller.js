import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["input", "clearButton"];

  // Trigger search on Enter key press
  handleEnter(event) {
    if (event.key === "Enter") {
      // No need to prevent form submission, allow it to happen
    }
  }

  connect() {
    console.log("Search controller connected");

    // Add an event listener to the clear button
    if (this.hasClearButtonTarget) {
      this.clearButtonTarget.addEventListener("click", () => {
        this.clearSearch();
      });
    }
  }

  // Clear the search input and trigger a new search with an empty query
  clearSearch() {
    this.inputTarget.value = ""; // Clear the search input
  const url = "/assignments"; // The URL for the assignments index

  // Redirect to the assignments index path
  window.location.href = url;
  }
}