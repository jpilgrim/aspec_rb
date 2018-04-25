require 'test/unit'
require 'asciidoctor'
require_relative '../lib/utils/utils'

class TestAssetLoader < Test::Unit::TestCase
  def test_create_header
    assert_nothing_raised do
      AssetLoader.new.create_header
    end
  end

  def test_create_footer
    assert_nothing_raised do
      AssetLoader.new.create_footer
    end
  end

  def test_create_search_page
    assert_nothing_raised do
     AssetLoader.new.create_search_page
    end
  end
end
