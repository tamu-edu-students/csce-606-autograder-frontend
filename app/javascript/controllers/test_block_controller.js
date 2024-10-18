import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["select", "testBlockPartial"];

  connect() {
    console.log("TestTypeController connected");
    this.loadTestBlockPartial();
    this.selectTarget.addEventListener("change", this.loadTestBlockPartial.bind(this));
  }

  loadTestBlockPartial() {
    console.log("Load Test Block Partial"); 
    const selectedTestType = this.selectTarget.value;

    console.log("Selected Test Type: ", selectedTestType);

    this.testBlockPartialTargets.forEach((partial) => {
      console.log("Partial: ", partial);
      if (partial.dataset.testType === selectedTestType) {
        partial.classList.remove("hidden");
      } 
      else {
        partial.classList.add("hidden");
      }
    });
  }

  disconnect() {
    this.selectTarget.removeEventListener("change", this.loadTestBlockPartial.bind(this));
  }
}
