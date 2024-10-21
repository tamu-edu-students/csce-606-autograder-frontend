// Update the URL with the selected test and open grouping IDs
function updateURL(element) {
    const url = new URL(window.location);
    const testId = element.dataset.test_id;
    

        // Ensure testId is defined before setting it in the URL
    if (testId) {
        url.searchParams.set("test_id", testId);
    } else {
        console.error("test_id is undefined");
    }
    // Retrieve open groupings and add them to the URL
    const openGroupings = Array.from(document.querySelectorAll('.dropdown-checkbox:checked'))
      .map(checkbox => checkbox.nextElementSibling.dataset.groupingId);
  
    url.searchParams.set("test_id", testId);
    if (openGroupings.length > 0) {
      url.searchParams.set("open_groupings", openGroupings.join(","));
    } else {
      url.searchParams.delete("open_groupings");
    }
  
    window.history.replaceState({}, '', url);
  }
  
  // On page load, keep the specified groupings open
  document.addEventListener("DOMContentLoaded", function() {
    const urlParams = new URLSearchParams(window.location.search);
    const openGroupings = urlParams.get("open_groupings");
  
    if (openGroupings) {
      openGroupings.split(",").forEach(id => {
        const checkbox = document.querySelector(`.dropdown-checkbox[id="group-${id}"]`);
        if (checkbox) {
          checkbox.checked = true;
        }
      });
    }
  });
  
