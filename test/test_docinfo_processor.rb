require 'test/unit'
require 'asciidoctor'
require_relative '../lib/utils/utils'

class TestDefintionBlock < Test::Unit::TestCase
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
end
