# frozen_string_literal: true

module Index
  # From the index, create an array of the main chapters
  def self.includes
    @indexincludes = []
    File.read('index.adoc').each_line do |line|
      next unless line[IncludeDirectiveRx]
      @indexincludes.push(match_include(line).sub(/^\{find\}/, '')) unless doc == 'config'
    end
    @indexincludes
  end

  def match_include(line)
    line.match(/(?<=^include::).+?\.adoc(?=\[\])/).to_s
  end
end
