# frozen_string_literal: true

require 'nokogiri'
require 'fileutils'
require 'open-uri'
require_relative '../extensions/utils/utils'

@json = ''
gendir = 'generated-docs' # TODO: - do not hardcode

html_files = Dir.glob("#{gendir}/**/*.html")

html_files.each do |file|
  next if file == "#{gendir}/search.html" || file[%r{^#{gendir}\/index}]

  page = Nokogiri::HTML(open(file))
  url = file.sub!(%r{^#{gendir}\/}, '')
  slug = file.sub(/\.html$/, '')
  title = page.css('h2').text

  page.xpath("//div[@class='sect1']").each do |section|

    if section.at_css('div.sect2')
      section.xpath("//div[@class='sect2' or @class='sect2 language-n4js']").each do |subsection|

        if subsection.at_css('div.sect3')
          section.xpath("//div[@class='sect3']").each do |subsection|

            if subsection.at_css('div.sect4')
              id = "\##{subsection.at('h5').attr('id')}"
              sub_url = url + id
              @json += Search.add_to_index(sub_url, id, subsection.at('h5').text, subsection.text)

            else
              id = "\##{subsection.at('h4').attr('id')}"
              sub_url = url + id
              @json += Search.add_to_index(sub_url, id, subsection.at('h4').text, subsection.text)
            end
          end

        else
          id = "\##{subsection.at('h3').attr('id')}"
          sub_url = url + id
          @json += Search.add_to_index(sub_url, id, subsection.at('h3').text, subsection.text)
        end
      end

    else
      text = section.xpath("//div[@class='sect1' or @class='sect1 language-n4js']").css('p').text
      @json += Search.add_to_index(url, slug, title, text)
    end
  end
end

jsonindex = %(<script>
window.data = {

#{@json}

};
</script>)

marker = '{{searchdata}}'
searchpage = "#{gendir}/search.html"

data = File.read(searchpage)
filtered_data = data.sub(marker, jsonindex)

File.open(searchpage, 'w') do |f|
  f.write(filtered_data)
end
