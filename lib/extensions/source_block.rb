# frozen_string_literal: true

require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'

Extensions.register do
  treeprocessor do
    process do |document|
      document.find_by context: :listing, style: 'source' do |src|
        src.lines.each do |li|
          li.gsub!(/\<\</, '« ')
          li.gsub!(/\>\>/, '»  ')
        end
        src
      end
    end
  end
end
