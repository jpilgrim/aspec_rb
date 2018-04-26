function search() {
    var input, filter, li, a, i;
    input = document.getElementById('pagesearch');
    filter = input.value.toUpperCase();
    li = document.getElementById("toc").getElementsByTagName('li');

    $('.collapse').collapse('show');
    // Loop through all list items, and hide those who don't match the search query
    for (i = 0; i < li.length; i++) {
        //a = li[i].getElementsByTagName("a")[0];
        if (li[i].innerHTML.toUpperCase().indexOf(filter) > -1) {
            li[i].style.display = "block";
            $(li[i]).addClass("found");
        } else {
            $(li[i]).removeClass("found");
            li[i].style.display = "none";
        }
    }
}

$("#clear").click(function(){
    $("#pagesearch").val('');
    search();
});
