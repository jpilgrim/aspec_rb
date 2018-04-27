# frozen_string_literal: true

module Search
  def self.add_to_index(file, slug, title, content)
    section = %(
    "#{slug}": {
        "id": "#{slug}",
        "title": "#{title}",
        "url": "#{file}",
        "content": "#{content}"
      },\n)
  end
end
