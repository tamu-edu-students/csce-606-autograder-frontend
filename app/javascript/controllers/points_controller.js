import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["totalPoints", "testInfo"]

  initialize() {
    document.addEventListener("turbo:load", () => this.connect())
  }

  connect() {
    console.log("Points controller connected")
    console.log("Total points target:", this.totalPointsTarget)
    console.log("Test info targets:", this.testInfoTargets)
    this.calculateTotalPoints()
  }

  calculateTotalPoints() {
    let totalPoints = 0
    console.log(`Number of testInfo targets: ${this.testInfoTargets.length}`)
    
    this.testInfoTargets.forEach((testInfo, index) => {
      const testText = testInfo.textContent.trim()
      console.log(`Test ${index + 1} content: "${testText}"`)
      const pointsText = testText.match(/\((\d+(?:\.\d+)?)\s*pts?\.\)/)
      if (pointsText && pointsText[1]) {
        const points = parseFloat(pointsText[1])
        totalPoints += points
        console.log(`Test ${index + 1}: ${points} points. Running total: ${totalPoints}`)
      } else {
        console.warn(`No points found for test ${index + 1}. Text content: "${testInfo.textContent}"`)
      }
    })

    console.log(`Final total points: ${totalPoints}`)
    this.totalPointsTarget.textContent = `Total Points: ${totalPoints}`
  }

  updatePoints(event) {
    const [data, status, xhr] = event.detail
    if (data && data.points !== undefined) {
      const testCard = event.target.closest('[data-points-target="testInfo"]')
      if (testCard) {
        const testInfo = testCard.querySelector('.test-info')
        if (testInfo) {
          testInfo.innerHTML = testInfo.innerHTML.replace(/\(\d+\s*pts?\.\)/, `(${data.points} pts.)`)
          console.log(`Updated points for a test. New text: "${testInfo.textContent}"`)
          this.calculateTotalPoints()
        }
      }
    }
  }
}