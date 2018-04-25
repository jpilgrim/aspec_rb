# frozen_string_literal: true

require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'
require_relative '../utils/utils'

Asciidoctor::Extensions.register do
  docinfo_processor do
    at_location :head
    process do |_doc|
      AssetLoader.new.create_header
    end
  end
end

Asciidoctor::Extensions.register do
  docinfo_processor do
    at_location :footer
    process do |_doc|
      AssetLoader.new.create_footer
    end
  end
end
