# frozen_string_literal: true

module Index
  def self.includes
    # From the index, create an array of the main chapters
    @indexincludes = []
    File.read('index.adoc').each_line do |li|
      next unless li[IncludeDirectiveRx]
      doc = li.match(/(?<=^include::).+?\.adoc(?=\[\])/).to_s
      doc = doc.sub(/^\{find\}/, '')
      @indexincludes.push(doc) unless doc == 'config'
    end
    @indexincludes
  end
end
