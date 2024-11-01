
  function loadTestPartial(testType) {
    fetch(`/test_blocks/${testType}`)
      .then(response => response.text())
      .then(html => {
        document.getElementById("dynamic-test-block-container").innerHTML = html;
      })
      .catch(error => console.error('Error loading test partial:', error));
  }

  function addNewField(containerId, placeholder, className = 'form-control mb-2') {
    console.log(`Add button clicked for container: ${containerId}`);
    const container = document.getElementById(containerId);
    if (container) {
      const newField = document.createElement('div');
      newField.className = `${containerId}-field`; // Dynamic class based on container ID
      newField.innerHTML = `<input type="text" 
                            name="test[test_block][${containerId}][]" 
                            class="${className}" 
                            placeholder="${placeholder}">`;
      container.appendChild(newField);
    } else {
      console.error(`${containerId} not found`);
    }
  }
  
  // Specific functions that call the generic addNewField function
  function addSourcePathField() {
    addNewField('source-paths-container', 'Enter Source Path');
  }
  
  function addCompilePathField() {
    addNewField('compile-file-container', 'Enter Compile Path');
  }
  
  function addMemoryErrorsPathField() {
    addNewField('memory-errors-container', 'Enter Memory Errors Path');
  }
  
  function addApprovedIncludesField() {
    addNewField('approved-includes-container', 'Enter Approved Includes');
  }
  
  window.loadTestPartial = loadTestPartial;
  window.addSourcePathField = addSourcePathField;
  window.addCompilePathField = addCompilePathField;
  window.addMemoryErrorsPathField = addMemoryErrorsPathField;
  window.addApprovedIncludesField = addApprovedIncludesField;