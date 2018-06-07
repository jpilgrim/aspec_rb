require 'nokogiri'
require 'fileutils'
require_relative '../extensions/utils/utils'

@json = ''
gendir = 'generated-docs' # TODO: - do not hardcode

html_files = Dir.glob("#{gendir}/**/*.html")

def add_heading(subsection, url, level)
  id = subsection.at(level).attr('id')
  sub_url = url + '#' + id
  @json << Search.add_to_index(sub_url, id, subsection.at(level).text, subsection.text)
end

Benchmark.bm do |bm|
  bm.report("fulltext search\n ") do
    html_files.each do |file|
      next if file == "#{gendir}/search.html" || file[%r{^#{gendir}\/index}]

      page = Nokogiri::HTML(open(file))
      url = file.sub!(%r{^#{gendir}\/}, '')
      slug = file.sub(/\.html$/, '')
      title = page.css('h2').text

      page.xpath("//div[@class='sect1']").each do |section|
        if section.at_css('div.sect2')

          # consider xpath for multiple cases - be more specific in the query, dont have so many nested ifs
          section.xpath("//div[@class='sect2' or @class='sect2 language-n4js']").each do |subsection|
            if subsection.at_css('div.sect3')

              section.xpath("//div[@class='sect3']").each do |subsection|
                add_heading(subsection, url, 'h4')
              end

            else
              add_heading(subsection, url, 'h3')
            end
          end


        else
          text = section.xpath("//div[@class='sect1' or @class='sect1 language-n4js']").css('p').text
          @json << Search.add_to_index(url, slug, title, text)
        end
      end
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
