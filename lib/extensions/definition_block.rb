require 'asciidoctor/extensions'

Extensions.register do
  block do
    named :def
    on_contexts :open, :paragraph, :example, :listing, :sidebar, :pass

    process do |parent, reader, attrs|
      # Add pass characters here to prevent html character replacements for < > tags
      pass = '+++'
      attrs['name'] = 'definition'
      attrs['caption'] = 'Definition: '
      nl = ''

      begin
        # downcase the title and replace spaces with underscores.
        #    Also replacing special HTML entities:
        #    &quot; = "
        #    &amp;  = &
        san_title = attrs['title'].gsub(/&/, '&amp;').delete('`').delete("'").delete('*')
      rescue StandardError => msg
        puts msg
        # If no title exists on the Def block, throw an exception
        puts '[ERROR] Definition block title missing'
      end

      alt = %(
<div class=\"panel panel-primary\">
<div class=\"panel-heading\">
<h3 class=\"panel-title\">
<a class=\"anchor\" href=\"##{san_title}\"></a>
<a class=\"link\" href=\"##{san_title}\"><emphasis role=\"strong\">Definition: </emphasis> #{san_title} </a>
</h3>
</div>
<div class=\"panel-body\">)

      close = '</div></div>'

      # concatenate all generated lines and prepend before the original content
      concat_lines = reader.lines.unshift(pass, alt, pass, nl)
      concat_lines.push(nl, pass, close, pass)

      create_block parent, :open, concat_lines, attrs, content_model: :compound
    end
  end
end
