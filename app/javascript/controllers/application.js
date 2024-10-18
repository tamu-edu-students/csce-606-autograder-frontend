import { Application } from "@hotwired/stimulus"
import TestBlockController from "controllers/test_block_controller"

const application = Application.start()

application.register("test_block", TestBlockController)

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
