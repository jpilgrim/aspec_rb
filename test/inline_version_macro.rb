require 'asciidoctor'
require 'test/unit'
require_relative '../lib/extensions/inline_version_macro'

class TestInlineTaskMacroProcessor < Test::Unit::TestCase
  def test_simple
    input = 'version:1[]'
    assert_equal("<div class=\"paragraph\">\n<p><div style=\"float:right;padding-left:0.1em;\"><a href=\"search.html?q=Version+1\" class=\"btn btn-primary btn-sm active\" role=\"button\" aria-pressed=\"true\">Version <span class=\"badge\">1</span></a></div></p>\n</div>",
                 Asciidoctor::Document.new(input).render)
  end
end
