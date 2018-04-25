# frozen_string_literal: true

require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'

# IO.readlines(File.join(__dir__, '../../assets/headers/docinfo.html')).join.to_s

header = IO.readlines(File.join(__dir__, '../../assets/headers/docinfo.html')).join.to_s
footer = IO.readlines(File.join(__dir__, '../../assets/headers/docinfo-footer.html')).join.to_s

stylesdir = Dir[File.join(__dir__, '../../assets/stylesheets/*')]
scriptsdir = Dir[File.join(__dir__, '../../assets/scripts/*')]

scripts = ''
styles = ''

def create_header(arr, scripts, header)
  arr.each do |file|
    asset = IO.readlines(file).join.to_s
    scripts += "<script> #{asset} </script>\n"
  end
  header + scripts
end

def create_footer(arr, styles, footer)
  arr.each do |file|
    asset = IO.readlines(file).join.to_s
    styles += "<style> #{asset} </style>\n"
  end
  styles += footer
  # footer
end

Asciidoctor::Extensions.register do
  docinfo_processor do
    at_location :head
    process do |_doc|
      create_header(scriptsdir, scripts, header)
    end
  end
end

Asciidoctor::Extensions.register do
  docinfo_processor do
    at_location :footer
    process do |_doc|
      create_footer(stylesdir, styles, footer)
    end
  end
end
