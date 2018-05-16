# frozen_string_literal: true

module Index
  def self.includes
    # From the index, create an array of the main chapters
    @indexincludes = []
    if File.exist? 'index.adoc'
      File.read('index.adoc').each_line do |line|
        @indexincludes.push(match_include(line).sub(/^\{find\}/, '')) if line[IncludeDirectiveRx]
      end
    end
    @indexincludes
  end

  def self.match_include(line)
    line.match(/(?<=^include::).+?\.adoc(?=\[\])/).to_s
  end
end
