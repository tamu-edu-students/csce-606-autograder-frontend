import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["input", "clearButton"];

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
};
