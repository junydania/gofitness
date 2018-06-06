$(document).on("turbolinks:load", function() {
    setTimeout(function(){
        $('#flash-message, #flash-box').remove();
    }, 3000)
 });
