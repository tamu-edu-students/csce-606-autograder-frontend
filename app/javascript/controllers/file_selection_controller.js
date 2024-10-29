import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    assignmentId: Number,
    tree: Array
  }

  static targets = ["targetField", "includeField", "targetDropdown", "includeDropdown"]

  connect() {
    console.log("Controller connected");
    // Initialize dropdowns
    this.targetField = document.getElementById("test_target");
    this.includeField = document.getElementById("test_include");
    this.targetDropdown = document.getElementById("target-file-tree-dropdown");
    this.includeDropdown = document.getElementById("include-file-tree-dropdown");

    // Clear existing content
    if (this.targetDropdown) this.targetDropdown.innerHTML = '';
    if (this.includeDropdown) this.includeDropdown.innerHTML = '';

    // Log tree value
    console.log("Tree value:", this.treeValue);

    // Render initial trees
    if (this.hasTreeValue) {
      this.renderTree(this.treeValue, this.targetDropdown);
      this.renderTree(this.treeValue, this.includeDropdown);
    }

    this.setupEventListeners();

    // After rendering the trees, check boxes based on existing values
    this.initializeCheckedBoxes(this.targetField, this.targetDropdown);
    this.initializeCheckedBoxes(this.includeField, this.includeDropdown);
  }

  initializeCheckedBoxes(field, dropdown) {
    if (field.value) {
      const selectedPaths = field.value.split(',').map(path => path.trim());
      const checkboxes = dropdown.querySelectorAll('.file-checkbox');
      
      checkboxes.forEach(checkbox => {
        if (selectedPaths.includes(checkbox.dataset.filePath)) {
          checkbox.checked = true;
        }
      });
    }
  }

  setupEventListeners() {
    if (this.targetField) {
      this.targetField.addEventListener("click", (e) => this.toggleDropdown(e));
    }
    if (this.includeField) {
      this.includeField.addEventListener("click", (e) => this.toggleDropdown(e));
    }
    document.addEventListener("click", (e) => this.hideDropdowns(e));
  }

  renderTree(nodes, container) {
    if (!container) return;

    const ul = document.createElement('ul');
    ul.className = 'file-tree';
    
    nodes.forEach(node => {
      const li = document.createElement('li');
      // Add both type and specific class for directories
      li.className = `${node.type} ${node.type}-item`;

      if (node.type === 'dir') {
        console.log("Creating directory:", node.name);
        const span = document.createElement('span');
        span.className = 'directory-name';
        span.textContent = node.name;
        span.dataset.path = node.path;
        // Add click event listener directly
        span.addEventListener('click', (e) => {
          console.log("Directory clicked:", node.name);
          this.toggleDirectory(e);
        });
        
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
    console.log("Toggle dropdown called");

    const field = event.currentTarget;
    const dropdown = field === this.targetField ? this.targetDropdown : this.includeDropdown;

    if (!dropdown) return;

    // Hide other dropdown
    if (dropdown === this.targetDropdown && this.includeDropdown) {
      this.includeDropdown.style.display = "none";
    } else if (this.targetDropdown) {
      this.targetDropdown.style.display = "none";
    }

    // Toggle current dropdown
    const isHidden = dropdown.style.display === "none";
    dropdown.style.display = isHidden ? "block" : "none";

    if (isHidden) {
      const fieldRect = field.getBoundingClientRect();
  
      // Position dropdown directly below the input field
      dropdown.style.position = 'absolute';
      dropdown.style.width = `${fieldRect.width}px`;
    }
  }

  updateField(event) {
    console.log("Update field called");
    const checkbox = event.target;
    const dropdown = checkbox.closest('.dropdown-content');
    if (!dropdown) {
      console.log("Dropdown not found");
      return;
    }

    const field = dropdown === this.targetDropdown ? this.targetField : this.includeField;
    if (!field) {
      console.log("Field not found");
      return;
    }
    
    // Get existing paths as array
    let selectedPaths = field.value ? field.value.split(',').map(path => path.trim()) : [];
    
    if (checkbox.checked) {
      // Add new path if it's not already in the array
      if (!selectedPaths.includes(checkbox.dataset.filePath)) {
        selectedPaths.push(checkbox.dataset.filePath);
      }
    } else {
      // Remove path if unchecked
      selectedPaths = selectedPaths.filter(path => path !== checkbox.dataset.filePath);
    }

    // Update field with joined paths
    field.value = selectedPaths.join(', ');
    console.log("Field updated with:", field.value);
  }

  hideDropdowns(event) {
    if (this.targetDropdown && !this.targetDropdown.contains(event.target) && event.target !== this.targetField) {
      this.targetDropdown.style.display = "none";
    }
    if (this.includeDropdown && !this.includeDropdown.contains(event.target) && event.target !== this.includeField) {
      this.includeDropdown.style.display = "none";
    }
  }
}