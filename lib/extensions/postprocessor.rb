# frozen_string_literal: true

require 'asciidoctor/extensions'

jquery = '<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>'
lt_gt = '(&gt;&gt;|&lt;&lt;)'

Extensions.register do
  postprocessor do
    process do |_document, output|
      # asciidoctor-latex injects an old version of jquery, causing conflicts,
      # see https://github.com/asciidoctor/asciidoctor-latex/blob/master/lib/asciidoctor/latex/inject_html.rb#L28
      output = output.sub(/#{jquery}/, '') if output[/#{jquery}/]
      # Remove angle brackets, add scrollspy for bootstrap, target nav.toc
      output.gsub(/#{lt_gt}/, '').sub(/<body class="book">/, '<body data-spy="scroll" data-target="#toc">')
    end
  end
end
