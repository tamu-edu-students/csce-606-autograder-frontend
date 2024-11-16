import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  initialize() {
    document.addEventListener("turbo:load", () => this.connect())
  }

  connect() {
    console.log("Points controller connected");
    console.log("Total points target:", this.totalPointsTarget);
    this.calculateTotalPoints()
  }

  updatePoints(event) {
    const form = event.target.closest('form');
    const formData = new FormData(form);

    console.log("Form found: ", form)

    console.log('FormData entries:', Array.from(formData.entries()));

    const pointsValue = formData.get('test[points]');
    console.log('Points value:', pointsValue);

    fetch(form.action, {
      method: 'POST',
      body: formData,
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        this.calculateTotalPoints()
        console.log(`Points updated to ${data.points}`);
      } else {
        console.error('Update failed:', data.error);
      }
    })
    .catch(error => {
      console.error('Error:', error);
    });
  }

  calculateTotalPoints() {
    console.log("calculateTotalPoints called");
    const totalPointsElement = document.getElementById("totalPoints");
    if (totalPointsElement) {
      const pointInputs = document.querySelectorAll('.points-input');
      console.log("Point inputs found:", pointInputs.length);
      let totalPoints = 0;
      pointInputs.forEach(input => {
        const points = parseFloat(input.value) || 0;
        console.log(`Input value: ${input.value}, Parsed value: ${points}`);
        totalPoints += points;
      });
      console.log("Calculated total points:", totalPoints);
      totalPointsElement.querySelector('span').textContent = totalPoints.toFixed(2);
      console.log("Total points updated in DOM");
    } else {
      console.error("Total points element not found");
    }
  }
}
