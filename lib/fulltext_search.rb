require 'asciidoctor'
require 'nokogiri'
require 'open-uri'

json = ''
gendir = 'generated-docs' # TODO: - do not hardcode
replacements = /"|\n|«|» |\s\s/

html_files = Dir.glob("#{gendir}/**/*.html")

html_files.each do |file|
  # Skip the search results and index pages
  next if file == "#{gendir}/search.html" || file[%r{^#{gendir}\/index}]

  page = Nokogiri::HTML(open(file))
  file.sub!(%r{^#{gendir}\/}, '')
  slug = file.sub(/\.html$/, '')

  h2 = page.css('h2').text
  text = page.css('p').text.gsub(replacements, ' ')

  content = %(
  "#{slug}": {
      "id": "#{slug}",
      "title": "#{h2}",
      "url": "#{file}",
      "content": "#{text}"
    },\n)
  json += content
end

jsonindex = %(<script>
window.data = {

#{json}

};
</script>)

marker = '{{searchdata}}'
searchpage = "#{gendir}/search.html"

data = File.read(searchpage)
filtered_data = data.sub(marker, jsonindex)

File.open(searchpage, 'w') do |f|
  f.write(filtered_data)
end

