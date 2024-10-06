// app/javascript/application.js

// Ensure Rails UJS is imported and started
import Rails from "@rails/ujs";
Rails.start();

// Turbo and other modules
import "@hotwired/turbo-rails";
import "controllers";
