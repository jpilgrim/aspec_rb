# frozen_string_literal: true

module Sform
  def self.trim(string)
    string = string.gsub(/^#{$srcdir}\//, '') unless string.nil?
    string = string.gsub(/(\.adoc)/, '') unless string.nil?
  end

  def self.underscorify(title)
    title = title.downcase.gsub(/(\s|-)/, '_')
    # document attribute idprefix must be seet to empty, if not
    # the default value is an underscore and the following line is required
    # t = t.prepend('_') unless t.match(/^_/)
    title = title.gsub(/___/, '_').delete('`')
  end

  def self.titleify(title)
    title = title.tr('_', ' ')
    title = title.lstrip
    title = title.split.map(&:capitalize).join(' ')
  end
end
