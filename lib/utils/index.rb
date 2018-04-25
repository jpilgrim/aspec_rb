# frozen_string_literal: true

# Reads the index document and gathers info about includes etc.
module Index
  def self.includes
    # From the index, create an array of the main chapters
    @indexincludes = []
    File.read('index.adoc').each_line do |line|
      @indexincludes.push(match_include(line).sub(/^\{find\}/, '')) if line[IncludeDirectiveRx]
    end
    @indexincludes
  end

  def self.match_include(line)
    line.match(/(?<=^include::).+?\.adoc(?=\[\])/).to_s
  end
end
