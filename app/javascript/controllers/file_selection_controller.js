import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    assignmentId: Number,
    tree: Array
  }

  static targets = [
    "targetField", "includeField", "targetDropdown", "includeDropdown",
    "mainPathField", "sourcePathField", "compilePathField",
    "memoryErrorsPathField", "inputPathField", "outputPathField",
    "scriptPathField"
  ];

  connect() {
    console.log("Controller connected");
    this.initializeDropdowns();
    window.initializeDropdowns = this.initializeDropdowns.bind(this);
  }

  initializeDropdowns() {
    // Dropdown fields
    this.targetField = document.getElementById("test_target");
    this.includeField = document.getElementById("test_include");
    console.log(this.includeField);
    this.mainPathField = document.getElementById("test_block_main_path");
    this.sourcePathField = document.getElementById("test_block_source_paths");
    this.compilePathField = document.getElementById("test_block_compile_paths");
    this.memoryErrorsPathField = document.getElementById("test_block_mem_error_paths");
    this.inputPathField = document.getElementById("test_block_input_path");
    this.outputPathField = document.getElementById("test_block_output_path");
    this.scriptPathField = document.getElementById("test_block_script_path");

    // Dropdown containers
    this.targetDropdown = document.getElementById("target-file-tree-dropdown");
    this.includeDropdown = document.getElementById("include-file-tree-dropdown");
    this.mainPathDropdown = document.getElementById("main-path-file-tree-dropdown");
    this.sourcePathDropdown = document.getElementById("source-path-file-tree-dropdown");
    this.compilePathDropdown = document.getElementById("compile-file-tree-dropdown");
    this.memoryErrorsPathDropdown = document.getElementById("mem-error-file-tree-dropdown");
    this.inputPathDropdown = document.getElementById("input-file-tree-dropdown");
    this.outputPathDropdown = document.getElementById("output-file-tree-dropdown");
    this.scriptPathDropdown = document.getElementById("script-file-tree-dropdown");

    // Render initial trees if available
    if (this.hasTreeValue) {
      [this.targetDropdown, this.includeDropdown, this.mainPathDropdown,
       this.sourcePathDropdown, this.compilePathDropdown, this.memoryErrorsPathDropdown,
       this.inputPathDropdown, this.outputPathDropdown, this.scriptPathDropdown
      ].forEach(dropdown => {
        // Check if the dropdown is already populated with the tree
        if (dropdown) {
          dropdown.innerHTML = ""; // Clear existing nodes if you want to refresh

          // Render the tree
          this.renderTree(this.treeValue, dropdown);
        }
      });
    }

    this.includeDropdown.style.display = "none";

    this.setupEventListeners();

    // Initialize dropdown content based on selected paths
    this.initializeCheckedBoxes(this.targetField, this.targetDropdown);
    this.initializeCheckedBoxes(this.includeField, this.includeDropdown);
    this.initializeCheckedBoxes(this.sourcePathField, this.sourcePathDropdown);
    this.initializeCheckedBoxes(this.compilePathField, this.compilePathDropdown);
    this.initializeCheckedBoxes(this.memoryErrorsPathField, this.memoryErrorsPathDropdown);
    this.initializeCheckedBoxes(this.scriptPathField, this.scriptPathDropdown);
    this.initializeRadioButtons(this.mainPathField, this.mainPathDropdown);
    this.initializeRadioButtons(this.inputPathField, this.inputPathDropdown);
    this.initializeRadioButtons(this.outputPathField, this.outputPathDropdown);
    
  }

  initializeRadioButtons(field, dropdown) {
    if (field && field.value && dropdown) {
      const selectedPath = field.value.trim();
      const radios = dropdown.querySelectorAll(".file-radio");
      radios.forEach(radio => {
        radio.checked = radio.dataset.filePath === selectedPath;
      });
    }
  }


  initializeCheckedBoxes(field, dropdown) {
    if (field && field.value && dropdown) {
      // Parse field.value as JSON if it looks like a stringified array
      let selectedPaths;
      try {
        selectedPaths = JSON.parse(field.value);
        if (selectedPaths.length === 0) {
          return
        }
        if (Array.isArray(selectedPaths) && typeof selectedPaths[0] === 'string') {
          // If it’s an array of strings, proceed as expected
          selectedPaths = selectedPaths.map(path => path.trim());
        } else if (Array.isArray(selectedPaths) && Array.isArray(selectedPaths[0])) {
          // If it’s an array within an array, flatten it
          selectedPaths = selectedPaths[0].map(path => path.trim());
        }
      } catch (e) {
        // If parsing fails, treat field.value as a comma-separated string
        selectedPaths = field.value.split(',').map(path => path.trim());
      }
      
      const checkboxes = dropdown.querySelectorAll('.file-checkbox');
      checkboxes.forEach(checkbox => {
        if (selectedPaths.includes(checkbox.dataset.filePath)) {
          checkbox.checked = true;
        }
      });
    }
  }
  

  setupEventListeners() {
    const fields = [
      this.targetField, this.mainPathField, this.sourcePathField,
      this.compilePathField, this.memoryErrorsPathField, this.inputPathField,
      this.outputPathField, this.scriptPathField
    ];

    fields.forEach(field => {
      if (field) {
        field.addEventListener("click", (e) => this.toggleDropdown(e));
      }
    });

    document.getElementById('includeDropdownMenuButton').addEventListener('click', (e) => {
      this.toggleDropdown(e);
      const arrow = document.getElementById("dropdownArrow");
      arrow.classList.toggle("rotated");
    });

    document.addEventListener("click", (e) => this.hideallDropdowns(e));
  }

  renderTree(nodes, container) {
    if (!container) return;

    const ul = document.createElement('ul');
    ul.className = 'file-tree';

    nodes.forEach(node => {
      const li = document.createElement('li');
      li.className = `${node.type} ${node.type}-item`;

      if (node.type === 'dir') {
        const span = document.createElement('span');
        span.className = 'directory-name';
        span.textContent = node.name;
        span.dataset.path = node.path;
        span.addEventListener('click', (e) => this.toggleDirectory(e));

        li.appendChild(span);

        if (node.children && node.children.length > 0) {
          const childContainer = document.createElement('ul');
          childContainer.className = 'directory-children';
          childContainer.style.display = 'none';
          this.renderTree(node.children, childContainer);
          li.appendChild(childContainer);
        }
      } else {
        const label = document.createElement('label');
        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        checkbox.className = 'file-checkbox';
        checkbox.dataset.filePath = node.path;
        checkbox.addEventListener('change', (e) => this.updateField(e));

        label.appendChild(checkbox);
        label.appendChild(document.createTextNode(node.name));
        li.appendChild(label);
      }

      ul.appendChild(li);
    });

    container.appendChild(ul);
  }

  toggleDirectory(event) {
    event.preventDefault();
    event.stopPropagation();
    console.log("Toggle directory called");

    const span = event.currentTarget;
    console.log("Span element:", span);
    console.log("Span parent:", span.parentElement);

    // Find the directory li element
    const directoryLi = span.parentElement;
    console.log("Directory li:", directoryLi);
    
    if (!directoryLi || !directoryLi.classList.contains('dir')) {
      console.log("Directory li not found or not a directory");
      return;
    }

    // Find the children container
    const childrenUl = directoryLi.querySelector('.directory-children');
    console.log("Children container:", childrenUl);
    
    if (!childrenUl) {
      console.log("Children ul not found");
      return;
    }

    const isHidden = childrenUl.style.display === 'none';
    childrenUl.style.display = isHidden ? 'block' : 'none';
    span.classList.toggle('expanded', isHidden);
    console.log("Directory toggled:", isHidden ? "shown" : "hidden");
  }


  toggleDropdown(event) {
    event.preventDefault();
    event.stopPropagation();
  
    const field = event.currentTarget;
    let dropdown;
  
    if (field.id === "includeDropdownMenuButton") {
      dropdown = this.includeDropdown;
    } else {
      dropdown = this.getDropdownForField(field);
    }
  
    if (!dropdown) return;
  
    // Hide all other dropdowns
    this.hideAllDropdownsExcept(dropdown);
  
    // Toggle current dropdown visibility
    const isHidden = dropdown.style.display === "none";
    dropdown.style.display = isHidden ? "block" : "none";
  
  }
  


  updateField(event) {
    console.log("Update field called");
    const checkbox = event.target;
    const dropdown = checkbox.closest('.dropdown-content');

    if (!dropdown) {
        console.log("Dropdown not found");
        return;
    }

    const field = this.getFieldForDropdown(dropdown);

    if (!field) {
        console.log("Field not found");
        return;
    }

    // Get existing paths as array
    let selectedPaths;
    if (field.id === "test_block_source_paths" || 
        field.id === "test_block_mem_error_paths" || 
        field.id === "test_block_compile_paths" ||
        field.id === "test_include") {
        // For these fields, keep them as arrays
        selectedPaths = field.value ? JSON.parse(field.value) : [];
    } else {
        // For other fields, keep the previous logic
        selectedPaths = field.value ? field.value.split(',').map(path => path.trim()) : [];
    }

    if (checkbox.checked) {
        // Add new path if it's not already in the array
        if (!selectedPaths.includes(checkbox.dataset.filePath)) {
            selectedPaths.push(checkbox.dataset.filePath);
        }
    } else {
        // Remove path if unchecked
        selectedPaths = selectedPaths.filter(path => path !== checkbox.dataset.filePath);
    }

    // Update field value based on field type
    if (field.id === "test_block_source_paths" || 
        field.id === "test_block_mem_error_paths" || 
        field.id === "test_block_compile_paths" ||
        field.id === "test_include") {
        // Store it as a JSON string for the input field
        field.value = JSON.stringify(selectedPaths);
    } else {
        // Join paths into a comma-separated string for other fields
        field.value = selectedPaths.join(', ');
    }

    console.log("Field updated with:", field.value);
  }



  getDropdownForField(field) {
    switch (field) {
      case this.targetField: return this.targetDropdown;
      case this.includeField: return this.includeDropdown;
      case this.mainPathField: return this.mainPathDropdown;
      case this.sourcePathField: return this.sourcePathDropdown;
      case this.compilePathField: return this.compilePathDropdown;
      case this.memoryErrorsPathField: return this.memoryErrorsPathDropdown;
      case this.inputPathField: return this.inputPathDropdown;
      case this.outputPathField: return this.outputPathDropdown;
      case this.scriptPathField: return this.scriptPathDropdown;
      default: return null;
    }
  }

  getFieldForDropdown(dropdown) {
    switch (dropdown) {
      case this.targetDropdown: return this.targetField;
      case this.includeDropdown: return this.includeField;
      case this.mainPathDropdown: return this.mainPathField;
      case this.sourcePathDropdown: return this.sourcePathField;
      case this.compilePathDropdown: return this.compilePathField;
      case this.memoryErrorsPathDropdown: return this.memoryErrorsPathField;
      case this.inputPathDropdown: return this.inputPathField;
      case this.outputPathDropdown: return this.outputPathField;
      case this.scriptPathDropdown: return this.scriptPathField;
      default: return null;
    }
  }

  hideAllDropdownsExcept(currentDropdown) {
    [
      this.targetDropdown, this.includeDropdown, this.mainPathDropdown,
      this.sourcePathDropdown, this.compilePathDropdown, this.memoryErrorsPathDropdown,
      this.inputPathDropdown, this.outputPathDropdown, this.scriptPathDropdown
    ].forEach(dropdown => {
      if (dropdown && dropdown !== currentDropdown) {
        dropdown.style.display = "none";
      }
    });
  }

  hideallDropdowns(event) {
    const dropdownFields = [
      { field: this.targetField, dropdown: this.targetDropdown },
      { field: this.includeField, dropdown: this.includeDropdown },
      { field: this.mainPathField, dropdown: this.mainPathDropdown },
      { field: this.sourcePathField, dropdown: this.sourcePathDropdown },
      { field: this.compilePathField, dropdown: this.compilePathDropdown },
      { field: this.memoryErrorsPathField, dropdown: this.memoryErrorsPathDropdown },
      { field: this.inputPathField, dropdown: this.inputPathDropdown },
      { field: this.outputPathField, dropdown: this.outputPathDropdown },
      { field: this.scriptPathField, dropdown: this.scriptPathDropdown }
    ];

    dropdownFields.forEach(({ field, dropdown }) => {
      if (dropdown && !dropdown.contains(event.target) && event.target !== field) {
        dropdown.style.display = "none";
      }
    });
  }
}

