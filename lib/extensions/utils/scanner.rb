module Sform
  def self.trim(s)
    s = s.gsub(/^#{$srcdir}\//, '') unless s.nil?
    s = s.gsub(/(\.adoc)/, '') unless s.nil?
  end

  def self.underscorify(t)
    t = t.downcase.gsub(/(\s|-)/, '_')
    # document attribute idprefix must be seet to empty, if not
    # the default value is an underscore and the following line is required
    # t = t.prepend('_') unless t.match(/^_/)
    t = t.gsub(/___/, '_').delete('`')
  end

  def self.titleify(t)
    t = t.tr('_', ' ')
    t = t.lstrip
    t = t.split.map(&:capitalize).join(' ')
  end
end
