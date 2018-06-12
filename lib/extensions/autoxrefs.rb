# frozen_string_literal: true

require 'asciidoctor/extensions'
require_relative 'utils/utils'

include ::Asciidoctor

# Read from config file - do NOT hard code the srcdir
$srcdir = 'chapters'

AnchorRx = /\[\[(?:|([\w+?_:][\w+?:.-]*)(?:, *(.+))?)\]\]/
ImageRx = /^(\.\S\w+)/
SectitleRx = /^(\=+\s+?\S+.+)/
XrefRx = /\<\<(?!Req)(.+?)\>\>/

ni_includes, includes, doclinks, anchorfixes, intrachapter, interchapter, anchors, xrefs = Array.new(9) { [] }

adoc_files = Dir.glob("#{$srcdir}/**/*.adoc")

indexincludes = Index.includes

# Scan adoc files and store some arrays of xrefs and anchors
adoc_files.each do |filename, main=false|
  path = Sform.trim(filename)
  chapter = path.match(/.+?(?=\/)/).to_s

  # If the current document is an include within the index.adoc
  indexincludes.each { |inc| main = true if inc == filename }

  File.read(filename).each_line do |li|
    h1 = false

    # Look for xrefs
    if li[XrefRx]
      # Handle multiple cross refs per line
      li.scan(/(?=\<\<(?!Req)(.+?)\>\>)/) do |xref|
        text = ''
        target = ''
        xref = xref[0].to_s
        target = xref.gsub(/\s/, '-')

        if xref[/,/]
          target = xref.gsub(/,.+/, '')
          text = xref.gsub(/.+,/, '').lstrip
          xref = xref.sub(/,.+/, '')
        elsif xref[/^SC_ROPR/]
          text = xref
        else
          text = Sform.titleify(xref).strip
        end
        xrefs.push([xref, path, filename, text, target, chapter])
      end

    # Section Titles
    elsif li[SectitleRx]
      h1 = true if li[/^=\s+?\S+.+/]
      title = li.chop.match(/(?!=+\s)(\S+.+?)$/i).captures[0].strip
      title.sub!(/\.(?=\w+?)/, '') if title[/\.(?=\w+?)/]
      link = Sform.underscorify(title)
      anchors.push([title, path, filename, link, chapter, main, h1])

    # Images
    elsif li[ImageRx]
      title = li.chop.match(/(?!=+\s)(\S+.+?)$/i).captures[0].strip
      title.sub!(/\.(?=\w+?)/, '') if title[/\.(?=\w+?)/]
      anchors.push([title, path, filename, title, chapter, main, h1])

    # Anchors
    elsif li[AnchorRx]
      anchor = li.chop.match(/(?<=\[\[).+?(?=\]\])/).to_s

      if anchor[/,/]
        anchor = anchor.match(/(?<=\[\[)(?:|[\w+?_:][\w+?:.-]*)(?=,.+?\]\])/).to_s
        text = anchor.sub(/.+?,/, '')
        text = text.sub(/\]\]$/, '')
      else
        text = anchor
      end

      anchors.push([anchor, path, filename, text, chapter, main, h1, true])

    # Match for includes
    elsif li[IncludeDirectiveRx]
      child = li.match(/(?<=^include::).+?\.adoc(?=\[\])/).to_s
      child = child.sub(/^\{find\}/, '')
      childpath = "#{filename.sub(/[^\/]+?\.adoc/, '')}#{child}"
      trim_childpath = Sform.trim(childpath)
      trim_parent = Sform.trim(filename)
      includes.push([filename, child, childpath, trim_childpath, trim_parent])

    end
  end
end

# Create array of non-index includes
adoc_files.each do |filename|
  includes.each do |parent, child, childpath, trim_childpath, trim_parent|
    next unless childpath == filename
    ni_includes.push([parent, child, filename, trim_childpath, trim_parent])
  end
end

# For each "main" include, store a target link
# This is where the generated HTML for each chapter will live
anchors.each do |_anchor, full, _filename, link, chapter, main, h1|
  next unless main && h1
  doc = full.gsub(/^#{chapter}\//, '')
  doclinks.push([doc, link, chapter])
end

# If a section title has an overriding anchor on the previous line, perform the following fix
o_anchors = []
doclinks.delete_if do |doc, _link, mchapter|
  topleveldoc = "#{$srcdir}/#{mchapter}/#{doc}.adoc"
  lines = File.foreach(topleveldoc).first(10).join
  next unless lines[/(?x)\[\[.+?\]\]\n=\s{1,}.+$/]
  overriding_anchor = lines.match(/(?x)\[\[(.+?)\]\]\n=\s{1,}.+$/).captures[0].to_s
  o_anchors.push([doc, overriding_anchor, mchapter])
  true
end

doclinks += o_anchors
doclinks.uniq!

# Edit the array of Anchors to point to the parent document if it is included.
tempanchors = []
3.times do
  tempanchors.clear

  # Loop through all includes, if the anchor is contained in an include,
  # edit the anchors array to point to its parent instead
  includes.each do |parent, _child, childpath, trim_childpath, trim_parent|
    anchors.delete_if do |anchor, path, filename, text, chapter, main, _h1|
      # TODO - this is a huge bottleneck!
      # remove string operations inside iterators!!!
      next unless trim_childpath == Sform.trim(filename)
      tempanchors.push([anchor, path, trim_parent, text, chapter, main])
      true
    end
  end

  anchors += tempanchors
  anchors.uniq!
  
end

tempanchors.clear

anchors.delete_if do |anchor, apath, trim_parent, parent, amain, achapter|
  doclinks.each do |doc, link, dchapter|
    next unless apath == "#{dchapter}/#{doc}" || trim_parent == "#{dchapter}/#{doc}"
    tempanchors.push([anchor, apath, link, parent, amain, achapter])
    true
  end
end

anchors += tempanchors
anchors.uniq!

# For all requirements, check which chapter they should finally be in with includes catered for
# match with a main document name - should be a main chapter title
xrefs.each do |xref, xpath, _xfilename, xtext, xtarget, _xchapter|
  anchors.each do |anchor, apath, afilename, atext, _achapter, _amain, _h1|
    next unless xref == anchor
    # if in same chapter, dont link to other HTML file
    afilename = '' if xpath == apath
    # xtext = xref if xtext.empty?
    afilename.sub!(/^_/, '') if afilename[/^_/]
    fix = "#{afilename}##{atext},#{xtext}"
    anchorfixes.push([anchor, fix, xref])
  end
end

anchorfixes.uniq!

Extensions.register do
  preprocessor do
    process do |_document, reader|
      Reader.new reader.readlines.map { |line|
        if line[/\<\<(?!Req)(.+?)\>\>/]
          anchorfixes.each do |original, fix|
            next unless line[/\<\<#{original}(,.+?)?\>\>/]
            line = line.sub(/\<\<#{original}(,.+?)?\>\>/, "\<\<#{fix}\>\>")
          end
        elsif line[/^(\=+\s+?\S+.+)/]
          line.delete!('`')
        elsif line[/^(\.\S\w+)/]
          line.delete!('\*_`')
        elsif line[/`.+`\s?::/]
          2.times { line.sub!(/`/, '') }
        end
        line
      }
    end
  end
end
