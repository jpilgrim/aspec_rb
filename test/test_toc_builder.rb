require 'test/unit'
require 'asciidoctor'
require_relative '../lib/utils/utils'

class TestTocHelper < Test::Unit::TestCase
  def test_scan_gen_files
    assert_nothing_raised do
      TocHelper.new.scan_gen_files('test/sample_docs/generated-docs')
    end
  end

  def test_build_toc
    assert_nothing_raised do
      anchors = TocHelper.new.scan_gen_files('test/sample_docs/generated-docs')
      TocHelper.new.build_toc(anchors)
    end
  end
end
