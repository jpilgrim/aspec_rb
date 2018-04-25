# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require_relative '../utils/utils'

TOC_MARKER = '{{inject_toc}}'
gendir = 'generated-docs' # do not hardcode
scanned_dir = TocHelper.new.scan_gen_files(gendir)

anchors = []

# For each Section (HTML page), create an array of anchors
scanned_dir.each do |sect, _title, filename|
  sect.each do |content|
    anchors.push([filename, content.attributes['id'].to_s, content.content.to_s, content.name.delete('h').to_i])
  end
end

html_files.each do |fi|
  file = fi.sub(%r{#{gendir}\/}, '')
  toc = TocHelper.new.build_toc(anchors).gsub(/#{file}/, '')
  data = File.read(fi)
  File.open(fi, 'w') do |f|
    modified = data.sub(TOC_MARKER, toc)
    f.write(modified)
  end
end
