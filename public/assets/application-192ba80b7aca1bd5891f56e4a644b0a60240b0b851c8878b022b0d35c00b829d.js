// app/javascript/application.js

// Ensure Rails UJS is imported and started
import Rails from "@rails/ujs";
Rails.start();

// Turbo and other modules
import "@hotwired/turbo-rails";
import "controllers";

import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus"

const application = Application.start()
const context = require.context("controllers", true, /\.js$/)
application.load(definitionsFromContext(context));
