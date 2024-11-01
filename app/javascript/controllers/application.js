import { Application } from "@hotwired/stimulus"
import TestGroupingCardController from "../controllers/test_grouping_card_controller"
import "../views/assignments/show"
import FileSelectionController from "./file_selection_controller"

const application = Application.start()

// Register the test_grouping_card controller
application.register("test_grouping_card", TestGroupingCardController)
application.register("file_selection", FileSelectionController)

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }



