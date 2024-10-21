// Ensure Rails UJS is imported and started
import Rails from "@rails/ujs";
Rails.start();

// Turbo and other modules
import "@hotwired/turbo-rails";

// Stimulus.js setup for controllers
import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";

// Start Stimulus application
const application = Application.start();
const context = require.context("controllers", true, /\.js$/);
application.load(definitionsFromContext(context));
