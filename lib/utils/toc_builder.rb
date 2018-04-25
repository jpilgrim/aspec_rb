# frozen_string_literal: true

require 'nokogiri'

# Loads some static assets like scripts and html templates
class TocHelper
  def initialize
    Encoding.default_external = Encoding::UTF_8
    Encoding.default_internal = Encoding::UTF_8
    @i = 0
    @prev_level = 0
    @toc = %(<input type="text" id="pagesearch" onkeyup="search()" placeholder="Filter chapters"
      style="margin-left: 18px;"><i class="fa fa-times" aria-hidden="true" style="display:none;"
       id="clear"></i> <ul class="nav" id="treeview">)
  end

  def scan_gen_files(gendir)
    anchors = []
    sections = []
    appendices = []
    html_files = Dir.glob("#{gendir}/**/*.html")
    html_files.each do |file|
      next if file == 'search.html'
      page = Nokogiri::HTML(open(file))
      filename = file.sub(%r{^#{gendir}\/}, '')
      # All Adoc files use a <h2> as  docname when sectnums attribute is enabled
      pagetitle = page.xpath('//h2').text
      # Exclude 'panel-title' class used in Requirements
      hs = page.xpath("//h2 | //h3[not(@class='panel-title')] | //h4 | //h5").collect
      if pagetitle[/^Appendix/]
        appendices.push([hs, pagetitle, filename])
      elsif pagetitle[/^\d+/]
        sections.push([hs, pagetitle, filename])
      end
    end
    sections.sort_by! { |_content, title| title.scan(/^\d+/).first.to_i }
    appendices.sort_by! { |_content, title| title } unless appendices.empty?
    sections + appendices unless appendices.empty?
    sections.each do |sect, _title, filename|
      sect.each do |content|
        anchors.push([filename, content.attributes['id'].to_s, content.content.to_s, content.name.delete('h').to_i])
      end
    end
    anchors
  end

  def build_toc(anchors)
    anchors.each do |file, id, text, level|
      li = "<li><a href=\"#{file}##{id}\">#{text}</a></li>\n"
      # If there are subsections, add a nested <ul> element
      if level > @prev_level
        if @i != 0
          @toc = @toc.chomp("</li>\n")
          @toc += %(<a href=\"#\" data-toggle=\"collapse\" data-target=\"#tocnav_#{id}\">
          <i class=\"fa fa-plus-square\" aria-hidden=\"true\"></i></a>
          <ul><div id=\"tocnav_#{id}\" class=\"collapse\"><li><a href=\"#{file}##{id}\">
          #{text}</a></li>\n)
          li = ''
        end
      # Close nested <ul> elements
      elsif level < @prev_level
        diff = @prev_level - level
        diff.times { @toc += "</div></ul>\n" }
      end
      @i += 1
      @toc += li
      @prev_level = level
    end
    @toc += '</ul>'
  end
end
