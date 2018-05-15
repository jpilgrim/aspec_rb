# frozen_string_literal: true

require 'asciidoctor/extensions'
require_relative 'utils/labels'
require_relative 'utils/block'

include ::Asciidoctor

Extensions.register do
  inline_macro do
    named :version

    process do |parent, target, attrs|
      attrs[:version] = true
      label = Labels.getstatus(attrs)
      html = Context.format(attrs, target, target, label)
      (create_pass_block parent, html, attrs).render
    end
  end
end
