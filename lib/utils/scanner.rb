# frozen_string_literal: true

# String operations often reused.
module Sform
  def self.trim(string)
    string&.gsub(%r{^#{$srcdir}\/}, '')
    string&.gsub(/\.adoc/, '')
  end

  def self.underscorify(title)
    title.downcase.gsub(/(\s|-)/, '_')
    # document attribute idprefix must be seet to empty, if not
    # the default value is an underscore and the following line is required
    # t = t.prepend('_') unless t.match(/^_/)
    title.gsub(/___/, '_').delete('`')
  end

  def self.titleify(title)
    title.tr('_', ' ')
    title.lstrip
    title.split.map(&:capitalize).join(' ')
  end
end
