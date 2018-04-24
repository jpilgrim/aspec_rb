/**
 * Copyright (c) 2016 NumberFour AG.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *   NumberFour AG - Initial API and implementation
 */

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
