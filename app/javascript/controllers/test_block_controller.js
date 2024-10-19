// app/javascript/controllers/test_block_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["testTypeSelect"];

  connect() {
    console.log("Test block controller connected");
  }

  updateTestBlock() {
    const testType = this.testTypeSelectTarget.value;
    const textBlock = document.getElementById('test-block-text');

    // Update text based on selected test type (this does not persist but updates the field)
    if (testType === 'coverage') {
      textBlock.value = "Enter details for coverage test...";
    } else if (testType === 'compile') {
      textBlock.value = "Enter details for compile test...";
    } else if (testType === 'approved_includes') {
      textBlock.value = "Enter details for approved includes test...";
    } else {
      textBlock.value = "Enter test details...";
    }
  }
}
