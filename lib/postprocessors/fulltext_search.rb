# frozen_string_literal: true

require 'nokogiri'
require 'fileutils'
require 'open-uri'

def html
  %(<!DOCTYPE html>
 <html lang="en">
 <head>
 <meta charset="UTF-8">
 <!--[if IE]><meta http-equiv="X-UA-Compatible" content="IE=edge"><![endif]-->
 <meta name="viewport" content="width=device-width, initial-scale=1.0">
 <meta name="generator" content="Asciidoctor 1.5.6.2">
 <title>Search</title>
 <!-- ************* Favicon ************-->
 <link rel="icon" href="styles/OPR.png"/>
 <!-- ************* Styles ************-->
 <link rel="stylesheet" href="styles/main.css">
 <link rel="stylesheet" href="styles/mix.css">
 <link rel="stylesheet" href="styles/prism.min.css">
 <!-- ************* JQuery ************* -->
 <script src="https://code.jquery.com/jquery-3.2.1.min.js"
   integrity="sha256-hwg4gsxgFZhOsEEamdOYGBf13FyQuiTwlAQgxVSNgt4="
   crossorigin="anonymous"></script>
 <!-- ************* UI Elements ************* -->
 <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.3/umd/popper.min.js"
         integrity="sha384-vFJXuSJphROIrBnz7yo7oB41mKfc8JzQZiCq4NCceLEaO4IHwicKwpJf9c9IpFgh"
         crossorigin="anonymous"></script>
 <!-- ************* Bootstrap JS ************* -->
 <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
 <!-- ************* Bootstrap Styles (place after bootstrap.js) ************-->
 <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
 <!-- ************* Icons ************-->
 <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.6.3/css/font-awesome.min.css">

 <!--Table of contents-->
 <nav id="toc" data-toggle="toc">
   <form action="search.html" method="get">
     <input type="text" name="q" id="search-input" placeholder="Full Text Search" autofocus>
     <input type="submit" value="Search" style="display: none;">
   </form>
   <ul class="index nav"><a id="index-link" href="index.html">
         <i class="fa fa-list-alt" aria-hidden="true"></i>
      Document Index
     </a></ul>
     ---TOC---
 </nav>

 </head>
 <body class="article">
 <div id="header">
 <h1>Search</h1>
 </div>
 <div id="content">
 <p><span id="search-process">Loading</span> results <span id="search-query-container" style="display: none;">for "<strong id="search-query"></strong>"</span></p>
 <ul id="search-results"></ul>
 </div>
 <div id="footer">
 <div id="footer-text">
 Last updated 2018-04-16 17:01:47 CEST
 </div>
 </div>
 <!-- ************* Prism.js Syntax Highlighting ************* -->
 <script src="scripts/prism.js"></script>
 <!-- ************* Load MathJax via CDN ************* -->
 <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>

 <script type="text/javascript">
     $(function () {
         $('[data-toggle="tooltip"]').tooltip()
     });

     $('.treeview').treeView();

     // Add the 'toclist' id for search function
     $(".toc > ul").attr('id', 'toclist');

     // Generate a Search input form
     $("#toclist > li:first-of-type").before('<i id="clear" class="fa fa-times-circle-o"></i>');
     $("#clear").click(function(){
         $("#pagesearch").val('');
         search();
     });
     //
     $('#pagesearch').on('click', function () {
         $('.collapse').collapse('toggle');
     });

 </script>

 <!-- Lunr search -->
 {{searchdata}}
 <script src="scripts/lunr.min.js"></script>
 <script src="scripts/search.js"></script>
 </body>
 </html>)
end

json = ''
gendir = 'generated-docs' # TODO: - do not hardcode
replacements = /"|\n|«|» |\s\s/

marker = '{{searchdata}}'
searchpage = "#{gendir}/search.html"

html_files = Dir.glob("#{gendir}/**/*.html")

html_files.each do |file|
  # Skip the search results and index pages
  next if file[%r{^#{gendir}\/index}]

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

filtered_data = html.sub(marker, jsonindex)

File.open(searchpage, 'w') do |f|
  f.write(filtered_data)
end
