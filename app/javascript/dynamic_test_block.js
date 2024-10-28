document.addEventListener("DOMContentLoaded", function() {
    // Find the form element
    const form = document.querySelector("#test-form");
    
    // Check if form is found
    console.log("Form found:", form);
  
    // Listen for the form's submit event
    form.addEventListener("submit", function(event) {
      // Get the value of the code block textarea
      const codeBlock = document.querySelector("#code_block")?.value || "";
      console.log("Code block value retrieved:", codeBlock); // Log code_block value
  
      // Populate the hidden field with the code block value
      const hiddenCodeBlock = document.querySelector("#hidden_code_block");
      hiddenCodeBlock.value = codeBlock;
      console.log("Hidden field updated with code block value:", hiddenCodeBlock.value); // Log hidden field value
    });
  });
  