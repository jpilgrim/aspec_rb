# frozen_string_literal: true

require 'asciidoctor'

# Chunks the HTML output generated by the HTML5 converter by chapter.
#
class MultipageHtml5Converter
  include Asciidoctor::Converter
  include Asciidoctor::Writer

  register_for 'multipage'
  EOL = "\n"

  def initialize(backend, opts)
    super
    basebackend 'html'
    @documents = []
  end

  def convert(node, transform = nil)
    transform ||= node.node_name
    send transform, node if respond_to? transform
  end

  def document(node)
    indexconfigs = {
      'stylesheet!' => true,
      'find' => '',
      'docinfodir' => 'headers',
      'docinfo1' => 'true'
    }
    node.blocks.each(&:convert)
    node.blocks.clear
    master_content = []
    master_content << %(= #{node.doctitle})
    master_content << (node.attr 'author') if node.attr? 'author'
    master_content << ''
    master_content << ''
    master_content << 'requirements::[]'
    Asciidoctor.convert master_content, doctype: node.doctype, header_footer: true, safe: node.safe, attributes: indexconfigs
  end

  def section(node)
    doc = node.document
    node.id.gsub!(/_2$/, '') if node.id[/_2$/]
    configs = doc.attributes.clone
    configs['noheader'] = ''
    configs['doctitle'] = node.title
    configs['backend'] = 'html'
    configs['stylesheet!'] = true
    page = Asciidoctor::Document.new [], header_footer: true, doctype: doc.doctype, safe: doc.safe, parse: true, attributes: configs

    page.set_attr 'docname', node.id
    reparent node, page

    page.blocks << node
    @documents << page
    ''
  end

  def reparent(node, parent)
    node.parent = parent
    node.blocks.each do |block|
      reparent block, node unless block.context == :dlist
      if block.context == :table
        block.columns.each do |col|
          col.parent = col.parent
        end
        block.rows.body = block.rows.body.map do |row|
          row.map do |cell|
            if cell.attributes['style'] == :asciidoc
              text = cell.instance_variable_get(:@text)
              Asciidoctor::Table::Cell.new cell.column, text, cell.attributes
            else
              cell
            end
          end
        end
      elsif block.context == :dlist
        block.parent = parent
        block.items.each do |i|
          reparent i[1], parent if i[1].respond_to? 'parent'
        end
      end
    end
  end

  def write(output, target)
    outdir = ::File.dirname target
    puts '[ASPEC] Generating chapters'
    @documents.each do |doc|
      filename = doc.attr 'docname'
      filename = filename.sub(/^_/, '')
      outfile = ::File.join outdir, %(#{filename}.html)
      ::File.open(outfile, 'w') do |f|
        f.write doc.convert
      end
    end
    ::File.open(target, 'w') do |f|
      f.write output
    end
    puts '[ASPEC] Done'
    puts "[ASPEC] Index generated at #{target}"
    load 'postprocessors/generate_toc.rb'
    load 'postprocessors/fulltext_search.rb'
  end
end
