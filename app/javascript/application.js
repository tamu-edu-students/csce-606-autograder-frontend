// app/javascript/application.js

// Ensure Rails UJS is imported and started
import Rails from "@rails/ujs";
Rails.start();

// Import Turbo and Stimulus
import { Application } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

// Import your custom Stimulus controllers
import TestBlockController from "./controllers/test_block_controller";

// Start Stimulus
const application = Application.start();
application.register("test-block", TestBlockController);

// Optional: Enable Stimulus development mode for debugging
application.debug = false;

export { application };
