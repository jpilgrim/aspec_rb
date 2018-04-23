# frozen_string_literal: true

require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'

main = File.join( __dir__, '../../assets/stylesheets/main.css' )
mixin = File.join( __dir__, '../../assets/stylesheets/mix.css' )
main_css = IO.readlines( main ).join.to_s
mix_css = IO.readlines( mixin ).join.to_s

Asciidoctor::Extensions.register do
  docinfo_processor do
    at_location :head
    process do |_doc|

      %(
      <style> #{main_css} </style>
      <style> #{mix_css} </style>)
    end
  end
end
