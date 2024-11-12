import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  //static targets = ["totalPoints", "testInfo"]

  initialize() {
    document.addEventListener("turbo:load", () => this.connect())
  }

  connect() {
    console.log("Points controller connected")
    // console.log("Total points target:", this.totalPointsTarget)
    // console.log("Test info targets:", this.testInfoTargets)
    // this.calculateTotalPoints()
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
        console.log(`Points updated to ${data.points}`);
      } else {
        console.error('Update failed:', data.error);
      }
    })
    .catch(error => {
      console.error('Error:', error);
    });
  }

  // calculateTotalPoints() {
  //   let totalPoints = 0
  //   console.log(`Number of testInfo targets: ${this.testInfoTargets.length}`)
    
  //   this.testInfoTargets.forEach((testInfo, index) => {
  //     const testText = testInfo.textContent.trim()
  //     console.log(`Test ${index + 1} content: "${testText}"`)
  //     const pointsText = testText.match(/\((\d+(?:\.\d+)?)\s*pts?\.\)/)
  //     if (pointsText && pointsText[1]) {
  //       const points = parseFloat(pointsText[1])
  //       totalPoints += points
  //       console.log(`Test ${index + 1}: ${points} points. Running total: ${totalPoints}`)
  //     } else {
  //       console.warn(`No points found for test ${index + 1}. Text content: "${testInfo.textContent}"`)
  //     }
  //   })

  //   console.log(`Final total points: ${totalPoints}`)
  //   this.totalPointsTarget.textContent = `Total Points: ${totalPoints}`
  // }

  // updatePoints(event) {
  //   const [data, status, xhr] = event.detail
  //   if (data && data.points !== undefined) {
  //     const testCard = event.target.closest('[data-points-target="testInfo"]')
  //     if (testCard) {
  //       const testInfo = testCard.querySelector('.test-info')
  //       if (testInfo) {
  //         testInfo.innerHTML = testInfo.innerHTML.replace(/\(\d+\s*pts?\.\)/, `(${data.points} pts.)`)
  //         console.log(`Updated points for a test. New text: "${testInfo.textContent}"`)
  //         this.calculateTotalPoints()
  //       }
  //     }
  //   }
  // }
}
