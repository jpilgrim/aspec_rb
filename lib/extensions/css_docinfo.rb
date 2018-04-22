# frozen_string_literal: true

require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'

Asciidoctor::Extensions.register do
  docinfo_processor do
    at_location :head
    process do |_doc|
      %(<style>
body {background-color: red}
</style>)
    end
  end
end
