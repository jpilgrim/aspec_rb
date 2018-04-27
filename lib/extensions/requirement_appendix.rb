# frozen_string_literal: true

require 'asciidoctor'
require 'asciidoctor/extensions'

exts = "(\.adoc|\.md|\.html)"
docsdir = 'chapters'

title = nil
chapter = nil
doctitle = nil
incs = []
inc_reqs = []
rows = []
coms = []
reqs = []

CommentBlockRx = %r(^\/{4,}$)
CommentLineRx = %r{^//(?=[^/]|$)}

def trim(s)
  s.gsub!(/chapters\//, '')
  s.gsub!(/(\.adoc|\.md|\.html)/, '')
end

adoc_files = Dir.glob('**/*.adoc')
adoc_files.sort!

adoc_files.each do |f|
  inc = false
  commented = false
  i = 0
  File.read(f).each_line do |li|
    i += 1
    incommentblock ^= true if li[CommentBlockRx]
    commented = true if li[CommentLineRx]

    if li[/\[\s*req\s*,\s*id\s*=\s*\w+-?[0-9]+\s*,.*/]
      title.sub!(/^\./, '')
      req = [li.chop, f, title]

      if commented || incommentblock
        coms.push(req)
      elsif inc
        inc_reqs.push(req)
      else
        reqs.push(req)
      end

    # Collect all includes
    elsif li[/^include::.+.adoc\[\]/]

      inc_file = li.chop.match(/(?<=^include::).+.adoc(?=\[\])/i).to_s
      inc_file = inc_file.sub(/^\{find\}/, '')
      path = inc_file.sub(/^#{docsdir}\//, '')
      path = path.sub(/#{exts}/, '')
      parent = f
      item = [inc_file, path, parent]
      incs.push item

    end
    title = li
  end
end

i = 0
reqs.each do |req, f, title, chapter, doctitle|
  i += 1
  link = ''
  # TODO: - find better solution for sanitized titles:
  title = title.delete('`').delete("'").delete('*')

  rid = /[^,]*\s*id\s*=\s*(\w+-?[0-9]+)\s*,.*/.match(req)[1]
  version = /(?<=version=)\d+/.match(req)

  f.gsub!(/^chapters\//, '')
  f.gsub!(/.adoc$/, '')

  $reqfixes.each do |id, fix|
    next unless id == rid
    link = "#{fix}.html##{rid}"
    break
  end

  link = link.sub(/^_/, '') if link[/^_/]
  f = f.sub(/^chapters\//, '')
  icon = '<i class="fa fa-external-link-square" aria-hidden="true"></i>'
  ref = "<a class=\"link\" href=\"#{link}\"><emphasis role=\"strong\">#{icon} #{title}</emphasis>  </a>"
  breadcrumb = "<a href=\"#{f}\">#{chapter} / #{doctitle}</a>"
  # anchor = "<a class=\"link\" href=\"#Req-#{rid}\">#{rid}</a>"
  row = %(<tr id="Req-#{rid}"> <th scope="row">#{i}</th> <td style="white-space:pre;">#{rid}</td>
  <td><span class="badge badge-primary badge-pill">#{version}</span></td> <td>#{ref}</td> <td>#{f}</td> </tr>)

  rows.push(row)
end

Asciidoctor::Extensions.register do
  block_macro :requirements do
    process do |parent, _target, _attrs|
      content = %(<h2 id="requirements"><a class="anchor" href="#requirements"></a>
      <a class="link" href="#requirements">Requirements</a></h2>
<div class="panel panel-default reqlist"> <div class="panel-heading"><h4>Requirements</h4></div>
<table class="table"> <thead> <tr>
<th>#</th> <th>ID</th><th>Version</th> <th>Title</th> <th>Source Document</th>
</tr> </thead>
<tbody>
#{rows.join}
</tbody>
</table> </div>)

      create_pass_block parent, content, {}
    end
  end
end
