
  function loadTestPartial(testType) {
    fetch(`/test_blocks/${testType}`)
      .then(response => response.text())
      .then(html => {
        document.getElementById("dynamic-test-block-container").innerHTML = html;
      })
      .catch(error => console.error('Error loading test partial:', error));
  }

  function addSourcePathField() {
    console.log("Add Source Path button clicked");
    const container = document.getElementById('source-paths-container');
    if (container) {
      const newField = document.createElement('div');
      newField.className = 'source-path-field';
      newField.innerHTML = `<input type="text" 
                            name="test[test_block][source_paths][]" 
                            class="form-control mb-2" 
                            placeholder="Enter Source Path">`;
      container.appendChild(newField);
    } else {
      console.error("source-paths-container not found");
    }
  }

  function addCompilePathField() {
    console.log("Add Compile Path button clicked");
    const container = document.getElementById('compile-file-container');
    if (container) {
      const newField = document.createElement('div');
      newField.className = 'file-path-field';
      newField.innerHTML = `<input type="text" 
                            name="test[test_block][file_paths][]" 
                            class="form-control mb-2" 
                            placeholder="Enter Compile Path">`;
      container.appendChild(newField);
    } else {
      console.error("compile-file-container not found");
    }
  }

  function addMemoryErrorsPathField() {
    console.log("Add Memory errors Path button clicked");
    const container = document.getElementById('memory-errors-container');
    if (container) {
      const newField = document.createElement('div');
      newField.className = 'file-path-field';
      newField.innerHTML = `<input type="text" 
                            name="test[test_block][file_paths][]" 
                            class="form-control mb-2" 
                            placeholder="Enter Memory Errors Path">`;
      container.appendChild(newField);
    } else {
      console.error("memory-errors-container not found");
    }
  }

  function addApprovedIncludesField() {
    console.log("Add Approved Includes button clicked");
    const container = document.getElementById('approved-includes-container');
    if (container) {
      const newField = document.createElement('div');
      newField.className = 'approved-includes-field';
      newField.innerHTML = `<input type="text" 
                            name="test[test_block][approved_includes][]" 
                            class="form-control mb-2" 
                            placeholder="Enter Approved Includes">`;
      container.appendChild(newField);
    } else {
      console.error("approved-includes-container not found");
    }
  }
  
  window.loadTestPartial = loadTestPartial;
  window.addSourcePathField = addSourcePathField;
  window.addCompilePathField = addCompilePathField;
  window.addMemoryErrorsPathField = addMemoryErrorsPathField;
  window.addApprovedIncludesField = addApprovedIncludesField;