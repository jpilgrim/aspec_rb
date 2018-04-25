# frozen_string_literal: true

require 'nokogiri'
require 'open-uri'
require_relative '../utils/utils'

TOC_MARKER = '{{inject_toc}}'
gendir = 'generated-docs' # do not hardcode

scanned_dir = TocHelper.new.scan_gen_files(gendir)
anchors = TocHelper.new.build_toc(scanned_dir)

html_files.each do |fi|
  file = fi.sub(%r{#{gendir}\/}, '')
  toc = TocHelper.new.build_toc(anchors).gsub(/#{file}/, '')
  data = File.read(fi)
  File.open(fi, 'w') do |f|
    modified = data.sub(TOC_MARKER, toc)
    f.write(modified)
  end
end
