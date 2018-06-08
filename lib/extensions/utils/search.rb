module Search
  # Some special handling for sanitizing the search json
  def self.sanitize_json(str)
    special_chars = /"|\n|«|» |\{|\}|…/
    str.gsub!(special_chars, ' ')
    str.gsub!(/\s+/, ' ')
    str.gsub!(/Unresolved directive.+\[\]/, '')
    str.gsub!(/\</, '&lt;') if str[/\</]
    str.gsub!(/\>/, '&gt;') if str[/\>/]
    str
  end

  def self.add_to_index(file, slug, title, content)
    section = %(
    "#{slug}": {
        "id": "#{slug}",
        "title": "#{title}",
        "url": "#{file}",
        "content": "#{sanitize_json(content)}"
      },\n)
  end
end
