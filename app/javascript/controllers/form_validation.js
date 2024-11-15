export function initializeFormValidation() {
    const form = document.querySelector("form[data-new-record='true']");
    if (!form) return; // Exit if the form is not in creation mode
    const testName = document.getElementById("test_name");
    const testPoints = document.getElementById("test_points");
    const testType = document.getElementById("test_type");
    const testTarget = document.getElementById("test_target");
    const targetAsterisk = document.getElementById("target-asterisk");
    const createButton = document.getElementById("create_test_button"); // specifically for "Create Test"
    // Function to check if all required fields are filled
    function checkRequiredFields() {
      const isNameFilled = testName && testName.value.trim() !== "";
      const isPointsFilled = testPoints && testPoints.value.trim() !== "";
      const isTypeSelected = testType && testType.value.trim() !== "";
      const isTargetRequired = testType && !["compile", "memory_errors", "script"].includes(testType.value);
      const isTargetFilled = testTarget && testTarget.value.trim() !== "";
      // Conditionally check Target field based on Test Type
      const allFieldsValid = isNameFilled && isPointsFilled && isTypeSelected &&
                             (!isTargetRequired || isTargetFilled);
      // Enable the button if all required fields are filled
      if (createButton) {
        createButton.disabled = !allFieldsValid;
      }
    }
    // Function to toggle Target field requirement based on Test Type
    function toggleTargetRequirement() {
      if (testType && ["compile", "memory_errors", "script"].includes(testType.value)) {
        // Make Target field optional
        if (testTarget) testTarget.required = false;
        if (targetAsterisk) targetAsterisk.style.display = "none";
      } else {
        // Make Target field required
        if (testTarget) testTarget.required = true;
        if (targetAsterisk) targetAsterisk.style.display = "inline";
      }
      checkRequiredFields(); // Re-check form validity
    }
    // Initial check for Target field requirement
    toggleTargetRequirement();
    // Add event listeners to check fields on change
    if (testName) testName.addEventListener("input", checkRequiredFields);
    if (testPoints) testPoints.addEventListener("input", checkRequiredFields);
    if (testType) testType.addEventListener("change", function() {
      toggleTargetRequirement();
      checkRequiredFields();
    });
    if (testTarget) testTarget.addEventListener("input", checkRequiredFields);
  }
  // Attach event listeners on Turbo load and frame rendering
  document.addEventListener("turbo:load", initializeFormValidation);
  document.addEventListener("turbo:frame-render", initializeFormValidation);