# frozen_string_literal: true

module Index
  def self.includes
    # From the index, create an array of the main chapters
    @indexincludes = []
    File.read('index.adoc').each_line do |line|
      next unless line[IncludeDirectiveRx]
      doc = match_include(line).sub(/^\{find\}/, '')
      @indexincludes.push(doc) unless doc == 'config'
    end
    @indexincludes
  end

  def self.match_include(line)
    line.match(/(?<=^include::).+?\.adoc(?=\[\])/).to_s
  end
end
