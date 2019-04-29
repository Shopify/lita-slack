require "lita"
require_relative "lita/http_callback"

Lita.load_locales Dir[File.expand_path(
  File.join("..", "..", "locales", "*.yml"), __FILE__
)]

require "lita/adapters/slack"
