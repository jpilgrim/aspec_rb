$(function () {
  $('[data-toggle="tooltip"]').tooltip()
});

// Add the 'toclist' id for search function
$(".toc > ul").attr('id', 'toclist');
// Generate a Search input form
$("#toclist > li:first-of-type").before('<i id="clear" class="fa fa-times-circle-o"></i>');

// on page Load. check if list item has a class, if so, expand the shits
$("a").click(function() {
  $(".active > ul > .collapse").collapse('show');
});

$( document ).ready(function() {
  $(".active > ul > .collapse").collapse('show');
});
