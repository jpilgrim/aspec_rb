require 'asciidoctor/extensions'
require_relative 'utils/scanner'

# test using ruby benchmark

include ::Asciidoctor

# Retrieve $srcdir from config file:
$srcdir = 'chapters'
$reqs = []
$doclinks = []

adoc_files = Dir.glob("#{$srcdir}/**/*.adoc")

# Find a nicer way to initialize some arrays:
ssincs, ni_includes, includes, doclinksfix, docs, titles, mainchaps, indexincludes, xrefs = Array.new(10) { [] }
$reqfixes = []

# From the index, create an array of the main chapters
File.read('index.adoc').each_line do |li|
  next unless li[IncludeDirectiveRx]
  doc = li.match(/(?<=^include::).+?\.adoc(?=\[\])/).to_s
  doc = doc.sub(/^\{find\}/, '')
  indexincludes.push(doc) unless doc == 'config'
end

adoc_files.sort!
adoc_files.each do |filename|
  main = false
  chapter = Sform.trim(filename).match(/.+?(?=\/)/).to_s

  # Add a switch if the current document is an include within the index.adoc
  indexincludes.each do |inc|
    main = true if inc == filename
  end

  # Create an array of chapters and contained docs
  docs.push([filename.sub(/^#{$srcdir}\//, ''), chapter])

  # Main iterator to check for requirements, anchors and xrefs line-by-line
  File.read(filename).each_line do |li|
    # Match Requirement Blocks "[req,ABC-123,version=n]"
    if li[/\[\s*req\s*,\s*id\s*=\s*(\w+-?[0-9]+)\s*,.*/]
      rid = li.chop.match(/id\s*=\s*(\w+-?[0-9]+)/i).captures[0]
      path = filename.sub(/^#{$srcdir}\//, '')
      $reqs.push([rid, li.chop, Sform.trim(path), filename, main, chapter])

    # Match block and section titles
    elsif li[/^(\=+\s+?\S+.+)/]
      # Keep track of level 1 sections (Document Titles)
      h1 = true if li[/^=\s+?\S+.+/]
      title = li.chop.match(/(?!=+\s)(\S+.+?)$/i).captures[0]
      title.sub!(/\.(?=\w+?)/, '') if title[/\.(?=\w+?)/]
      title = title.strip
      titles.push([title, Sform.trim(filename), filename, Sform.underscorify(title).strip, chapter, main, h1])

    # Match for sub includes
    elsif li[IncludeDirectiveRx]
      child = li.match(/(?<=^include::).+?\.adoc(?=\[\])/).to_s
      child = child.sub(/^\{find\}/, '')
      childpath = "#{filename.sub(/[^\/]+?\.adoc/, '')}#{child}"
      includes.push([filename, child, childpath])

    end
  end
end

# TODO: - remove unused items in array (prefixed with undserscore)
# For each main include, store
titles.each do |_anchor, full, _filename, text, chapter, main, h1|
  next unless main
  doc = full.gsub(/^#{chapter}\//, '')
  mainchaps.push([chapter, doc, text, h1])
end

# H1 title is used by html-chunker.rb to generate
# a target document name, e.g. for "= Document Title" the generated chapter
# will have a filename of "_document_title.html", all requirements
# within this chapter and its includes need to point to this H1
# NOTE: this will fail if the h1 title is overridden, this is resolved
# by the next block
mainchaps.each do |mchapter, doc, link, h1|
  next unless h1
  $doclinks.push([doc, link, mchapter])
end

# For edge cases - slurp the first 10 lines of each top level document and
# search for an overridden H1 - the previous line will be an anchor
$doclinks.delete_if do |doc, _link, mchapter|
  topleveldoc = "#{$srcdir}/#{mchapter}/#{doc}.adoc"
  lines = File.foreach(topleveldoc).first(10).join
  next unless lines[/(?x)\[\[.+?\]\]\n=\s{1,}.+$/]
  overriding_anchor = lines.match(/(?x)\[\[(.+?)\]\]\n=\s{1,}.+$/).captures[0].to_s
  doclinksfix.push([doc, overriding_anchor, mchapter])
  true
end

# TODO: - see if editing the array in-place is better using map!
$doclinks += doclinksfix

# Create array of non-indexed includes
adoc_files.each do |filename|
  includes.each do |parent, child, childpath|
    next unless childpath == filename
    ni_includes.push([parent, child, filename])
  end
end

# TODO: - see if editing the array in-place is better using map!
includes += ni_includes

# Edit the array of Requirements to point to the parent document *if* it is included.
# TODO use a while loop, repeat until no changes made
3.times do
  # initialize an array
  tempreqs = []

  # Loop through all includes, if the requirement is contained in an include,
  # edit the $reqs array to point to its parent instead
  includes.each do |parent, _child, childpath|
    # Delete the child req if matched
    $reqs.delete_if do |rid, line, path, _filename, main, chapter|
      next unless Sform.trim(childpath) == Sform.trim(path)
      tempreqs.push([rid, line, Sform.trim(parent), parent, main, chapter])
      true
    end
  end

  # TODO: - see if editing the array in-place is better using map!
  $reqs += tempreqs
  $reqs.uniq!
end

# Sort in-place by numberic ID
$reqs.sort_by!(&:first)

# For all requirements, check which chapter they should finally be in with includes catered for
# match with a main document name - should be a main chapter title
$reqs.each do |rid, _line, path, _filename, _main, _chapter|
  $doclinks.each do |_doc, link, chapter|
    next unless path == "#{chapter}/#{_doc}"
    $reqfixes.push([rid, link])
    break
  end
end

# RexRx = /(?<=(?<!\\)&lt;&lt;)(Req-\w+-?.+?)(?=&gt;&gt;)/
RexRx = /(?<=&lt;&lt;)(Req-\w+-?.+?)(?=&gt;&gt;)/

# TODO: consider a more performant way of matching the requirements here
Extensions.register do
  inline_macro do
    named :reqlink

    match RexRx
    process do |parent, target|
      id = target.sub(/^Req-/, '')
      msg = ''
      fix = ''

      if target[/,/]
        msg = target.match(/(?<=,).+/).to_s.strip
        id = target.sub(/^Req-/, '').sub(/,.+/, '')
        icon = '<i class="fa fa-info-circle" aria-hidden="true"></i>'
      end

      displaytext = id

      $reqfixes.each do |fixid, file|
        next unless fixid == id
        fix = file
        break
      end

      tooltip = if msg != ''
                  "data-toggle=\"tooltip\" data-placement=\"top\" title=\"#{msg}\""
                else
                  ''
                end

      fix = fix.sub(/^_/, '') if fix[/^_/]
      link = id.sub(/^Req-/, '')
      uri = "#{fix}.html##{link}"
      uri = "##{link}" if fix == ''
      o = "<span class=\"label label-info\" #{tooltip}>"
      c = '</span>'
      (create_anchor parent, %(#{o} #{icon} #{displaytext}#{c}), type: :link, target: uri).convert
    end
  end
end
