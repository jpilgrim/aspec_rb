# frozen_string_literal: true

class AssetLoader
  def initialize
    @header = IO.readlines(File.join(__dir__, '../../assets/html/docinfo.html')).join.to_s
    @footer = IO.readlines(File.join(__dir__, '../../assets/html/docinfo-footer.html')).join.to_s
    @stylesdir = 'assets/stylesheets'
    @scriptsdir = 'assets/scripts'
  end

  def create_header
    @scripts = ''
    Dir[File.join(__dir__, "../../#{@scriptsdir}/*")].each do |file|
      asset = IO.readlines(file).join.to_s
      @scripts += "<script> #{asset} </script>\n"
    end
    @header + @scripts
  end

  def create_footer
    @styles = ''
    Dir[File.join(__dir__, "../../#{@stylesdir}/*")].each do |file|
      asset = IO.readlines(file).join.to_s
      @styles += "<style> #{asset} </style>\n"
    end
    @styles + @footer
  end
end
