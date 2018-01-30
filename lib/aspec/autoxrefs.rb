require 'asciidoctor/extensions'
require_relative 'utils/scanner'

include ::Asciidoctor

# Read from config file - do NOT hard code the srcdir
$srcdir = 'chapters'
invoc = Dir.pwd

AnchorRx = /\[\[(?:|([\w+?_:][\w+?:.-]*)(?:, *(.+))?)\]\]/

indexincludes, ni_includes, includes, doclinks, anchorfixes, intrachapter, interchapter, anchors, xrefs = Array.new(10) { [] }

adoc_files = Dir.glob("#{$srcdir}/**/*.adoc")

# From the index, create an array of the main chapters
File.read('index.adoc').each_line do |li|
  if li[IncludeDirectiveRx]
    doc = li.match(/(?<=^include::).+?\.adoc(?=\[\])/).to_s
    doc = doc.sub(/^\{find\}/, '')
    indexincludes.push(doc) unless doc == 'config'
  end
end

adoc_files.each do |filename|
  main = false
  path = Sform.trim(filename)
  chapter = path.match(/.+?(?=\/)/).to_s

  # Add a switch if the current document is an include within the index.adoc
  indexincludes.each do |inc|
    main = true if inc == filename
  end

  File.read(filename).each_line do |li|
    h1 = false

    if li[/\<\<(?!Req)(.+?)\>\>/]
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
        else
          text = Sform.titleify(xref).strip
        end
        xrefs.push([xref, path, filename, text, target, chapter])
      end

    elsif li[/^(\=+\s+?\S+.+)/]
      h1 = true if li[/^=\s+?\S+.+/]
      title = li.chop.match(/(?!=+\s)(\S+.+?)$/i).captures[0].strip
      title.sub!(/\.(?=\w+?)/, '') if title[/\.(?=\w+?)/]
      link = Sform.underscorify(title)
      anchors.push([title, path, filename, link, chapter, main, h1])

    # Handle images separately
    elsif li[/^(\.\S\w+)/]
      title = li.chop.match(/(?!=+\s)(\S+.+?)$/i).captures[0].strip
      title.sub!(/\.(?=\w+?)/, '') if title[/\.(?=\w+?)/]
      anchors.push([title, path, filename, title, chapter, main, h1])

    elsif li[/\[\[(?:|([\w+?_:][\w+?:.-]*)(?:, *(.+))?)\]\]/]
      anchor = li.chop.match(/(?<=\[\[).+?(?=\]\])/).to_s

      if anchor[/,/]
        anchor = anchor.match(/(?<=\[\[)(?:|[\w+?_:][\w+?:.-]*)(?=,.+?\]\])/).to_s
        text = anchor.sub(/.+?,/, '')
        text = text.sub(/\]\]$/, '')
      else
        text = anchor
      end

      anchors.push([anchor, path, filename, text, chapter, main, h1, true])

    # Match for sub includes
    elsif li[IncludeDirectiveRx]
      child = li.match(/(?<=^include::).+?\.adoc(?=\[\])/).to_s
      child = child.sub(/^\{find\}/, '')
      childpath = "#{filename.sub(/[^\/]+?\.adoc/, '')}#{child}"
      includes.push([filename, child, childpath])

    end
  end
end

# Create array of non-indexed includes
adoc_files.each do |filename|
  includes.each do |parent, child, childpath|
    next unless childpath == filename
    ni_includes.push([parent, child, filename])
  end
end

# For each main include, store a target link
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

# Edit the array of Anchors to point to the parent document *if* it is included.
# TODO use a while loop, repeat until no changes made
tempanchors = []
3.times do
  tempanchors.clear

  # Loop through all includes, if the anchor is contained in an include,
  # edit the anchors array to point to its parent instead
  includes.each do |parent, _child, childpath|
    anchors.delete_if do |anchor, path, filename, text, chapter, main, _h1|
      next unless Sform.trim(childpath) == Sform.trim(filename)
      tempanchors.push([anchor, path, Sform.trim(parent), text, chapter, main])
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
xrefs.each do |xref, xpath, _xfilename, xtext, _xtarget, _xchapter|
  anchors.each do |anchor, apath, afilename, atext, _achapter, _amain, _h1|
    next unless xref == anchor
    # if in same chapter, dont link to other HTML file
    afilename = '' if xpath == apath
    xtext = Sform.titleify(xref) if xtext.empty?
    afilename.sub!(/^_/, '') if afilename[/^_/]
    fix = "#{afilename}##{atext},#{xtext}"
    anchorfixes.push([anchor, fix, xref])
  end
end

Extensions.register do
  preprocessor do
    process do |_document, reader|
      Reader.new reader.readlines.map { |line|
        if line[/\<\<(?!Req)(.+?)\>\>/]
          anchorfixes.each do |original, fix|
            next unless line[/\<\<#{original}(,.+?)?\>\>/]
            line = line.sub(/\<\<#{original}(,.+?)?\>\>/, "icon:angle-double-up[] <<#{fix}>>")
          end
        end
        line
      }
    end
  end
end
