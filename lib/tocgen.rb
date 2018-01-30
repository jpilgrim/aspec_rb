require 'nokogiri'
require 'open-uri'

# This marker should be in the target document where the TOC will be placed.
marker = '---TOC---'
gendir = '../generated-docs' # TODO: - do not hardcode

# Open a <ul> element
toc = %{<input type="text" id="pagesearch" onkeyup="search()" placeholder="Filter chapters"
style="margin-left: 18px;">
<i class="fa fa-times" aria-hidden="true" style="display:none;" id="clear"></i>
<ul class="nav" id="treeview">

}

html_files = Dir.glob("#{gendir}/**/*.html")

anchors, sections, appendices = [], [], []

html_files.each do |file|
  next if file == "#{gendir}/search.html" || file[%r{^#{gendir}\/index}]
  page = Nokogiri::HTML(open(file))
  filename = file.sub(%r{^#{gendir}\/}, '')

  # All Asciidoc files will have a <h2> element as the document name
  # when sectnums attribute is enabled, this can be used for sorting
  pagetitle = page.xpath('//h2').text

  # Collect all heading elements, exclude 'panel-title' class used in Requirements
  # TODO - check for other heading elements that are not section titles.
  # It may be wise to search by xpath for heading elements directly after 'sect1-6' class divs
  hs = page.xpath("//h2 | //h3[not(@class='panel-title')] | //h4 | //h5").collect

  if pagetitle[/^Appendix/]
    # Create an array of appendices
    appendices.push([hs, pagetitle, filename])
  elsif pagetitle[/^\d+/]
    # Create an array of section titles by chapter number
    sections.push([hs, pagetitle, filename])
  end
end

# Sort Sections by number
sections.sort_by! { |_content, title| title.scan(/^\d+/).first.to_i }

# Sort Appendices Array
appendices.sort_by! { |_content, title| title }

# Push Appendices to end of Sections array
appendices.each do |content, title, filename|
  sections.push([content, title, filename])
end

# For each Section (HTML page), create an array of anchors
sections.each do |sect, _title, filename|
  sect.each do |content|
    anchors.push([filename, content.attributes['id'].to_s, content.content.to_s, content.name.delete('h').to_i])
  end
end

i = 0
prev_level = 0

# For each anchor, create a html list element
anchors.each do |file, id, text, level|
  li = "<li><a href=\"#{file}##{id}\">#{text}</a></li>\n"

  # If there are subsections, add a nested <ul> element
  if level > prev_level
    if i != 0
      toc = toc.chomp("</li>\n")
      toc += " <a href=\"#\" data-toggle=\"collapse\" data-target=\"#tocnav_#{id}\"><i class=\"fa fa-plus-square\"
      aria-hidden=\"true\"></i></a>
      <ul>
      <div id=\"tocnav_#{id}\" class=\"collapse\">
      <li><a href=\"#{file}##{id}\">#{text}</a></li>\n"
      li = ''
    end

  # Close nested <ul> elements
  elsif level < prev_level
    diff = prev_level - level
    diff.times { toc += "</div></ul>\n" }
  end
  i += 1
  toc += li
  # assign a variable with current level to compare in next iteration
  prev_level = level
end

# Close the toc
toc += '</ul>'

html_files.each do |fi|
  file = fi.sub(%r{#{gendir}\/}, '')
  thistoc = toc.gsub(/#{file}/, '')
  data = File.read(fi)
  File.open(fi, 'w') do |f|
    modified = data.sub(marker, thistoc)
    f.write(modified)
  end
end
