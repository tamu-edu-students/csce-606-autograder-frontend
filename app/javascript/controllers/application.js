import { Application } from "@hotwired/stimulus"
import TestGroupingCardController from "../controllers/test_grouping_card_controller"
import TestCardController from "../controllers/test_card_controller"
import "../views/assignments/show"
import PointsController from "./points_controller"

const application = Application.start()

// Register the test_grouping_card controller
application.register("test_grouping_card", TestGroupingCardController)
application.register("test_card", TestCardController)
application.register("points", PointsController)

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }



